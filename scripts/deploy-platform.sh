#!/bin/bash
# Automated Deployment Script for Dry Fruits Platform
# Agent-friendly with JSON output and proper error handling

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_DIR/k8s"

# Load environment variables if available
if [[ -f "$PROJECT_DIR/.env.ocp" ]]; then
    source "$PROJECT_DIR/.env.ocp"
fi

# Script options
DRY_RUN="${DRY_RUN:-false}"
JSON_OUTPUT="${JSON_OUTPUT:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log() {
    if [[ "$VERBOSE" == "true" || "$1" == "ERROR" || "$1" == "SUCCESS" ]]; then
        local level="$1"
        shift
        local message="$*"
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        case $level in
            "ERROR")   echo -e "${RED}[ERROR]${NC} [$timestamp] $message" >&2 ;;
            "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} [$timestamp] $message" ;;
            "WARNING") echo -e "${YELLOW}[WARNING]${NC} [$timestamp] $message" ;;
            "INFO")    echo -e "${BLUE}[INFO]${NC} [$timestamp] $message" ;;
            "DEBUG")   if [[ "$VERBOSE" == "true" ]]; then echo -e "${CYAN}[DEBUG]${NC} [$timestamp] $message"; fi ;;
        esac
    fi
}

# JSON output function
json_output() {
    local status="$1"
    local message="$2"
    local data="${3:-{}}"
    
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        local timestamp
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "{\"status\":\"$status\",\"message\":\"$message\",\"timestamp\":\"$timestamp\",\"data\":$data}" | jq -c .
    fi
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check required tools
    for tool in oc kubectl jq; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log "ERROR" "Missing required tools: ${missing_tools[*]}"
        json_output "error" "Missing prerequisites" "{\"missing_tools\":[\"$(IFS='","'; echo "${missing_tools[*]}")\"]}"
        exit 1
    fi
    
    # Check if logged into OpenShift
    if ! oc whoami &>/dev/null; then
        log "ERROR" "Not logged into OpenShift. Run ocp-login.sh first."
        json_output "error" "Not authenticated"
        exit 1
    fi
    
    # Check if K8s directory exists
    if [[ ! -d "$K8S_DIR" ]]; then
        log "ERROR" "K8s directory not found: $K8S_DIR"
        json_output "error" "K8s directory not found"
        exit 1
    fi
    
    log "SUCCESS" "Prerequisites check passed"
    json_output "info" "Prerequisites validated"
}

# Apply K8s resource
apply_resource() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    
    log "INFO" "Applying $filename..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would apply $filename"
        oc apply -f "$file" --dry-run=client
        json_output "info" "Dry run successful" "{\"file\":\"$filename\"}"
        return 0
    fi
    
    local output
    local exit_code
    
    if output=$(oc apply -f "$file" 2>&1); then
        exit_code=0
        log "SUCCESS" "Applied $filename successfully"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "$output"
        fi
        json_output "success" "Resource applied" "{\"file\":\"$filename\",\"output\":\"$output\"}"
    else
        exit_code=$?
        log "ERROR" "Failed to apply $filename: $output"
        json_output "error" "Resource application failed" "{\"file\":\"$filename\",\"error\":\"$output\"}"
        
        if [[ "$FORCE" != "true" ]]; then
            exit $exit_code
        fi
    fi
    
    return $exit_code
}

# Wait for pods to be ready
wait_for_pods() {
    local namespace="$1"
    local timeout="${2:-300}"
    
    log "INFO" "Waiting for pods in namespace '$namespace' to be ready (timeout: ${timeout}s)..."
    
    local start_time
    start_time=$(date +%s)
    
    while true; do
        local current_time
        current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -gt $timeout ]]; then
            log "ERROR" "Timeout waiting for pods to be ready"
            json_output "error" "Pod readiness timeout"
            return 1
        fi
        
        # Get pod status
        local pending_pods
        local failed_pods
        pending_pods=$(oc get pods -n "$namespace" --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l || echo "0")
        failed_pods=$(oc get pods -n "$namespace" --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l || echo "0")
        
        if [[ "$failed_pods" -gt 0 ]]; then
            log "ERROR" "Found $failed_pods failed pods"
            oc get pods -n "$namespace" --field-selector=status.phase=Failed
            json_output "error" "Pods failed" "{\"failed_count\":$failed_pods}"
            return 1
        fi
        
        if [[ "$pending_pods" -eq 0 ]]; then
            log "SUCCESS" "All pods are ready"
            json_output "success" "All pods ready"
            return 0
        fi
        
        log "DEBUG" "Waiting... ($pending_pods pending pods, elapsed: ${elapsed}s)"
        sleep 5
    done
}

# Get deployment status
get_deployment_status() {
    local namespace="$1"
    
    log "INFO" "Getting deployment status for namespace '$namespace'..."
    
    # Get pods
    local pods_info
    pods_info=$(oc get pods -n "$namespace" -o json 2>/dev/null || echo '{"items":[]}')
    
    # Get services
    local services_info
    services_info=$(oc get services -n "$namespace" -o json 2>/dev/null || echo '{"items":[]}')
    
    # Get routes
    local routes_info
    routes_info=$(oc get routes -n "$namespace" -o json 2>/dev/null || echo '{"items":[]}')
    
    # Combine into status object
    local status_json
    status_json=$(jq -n \
        --argjson pods "$pods_info" \
        --argjson services "$services_info" \
        --argjson routes "$routes_info" \
        '{
            pods: $pods.items | length,
            services: $services.items | length,
            routes: $routes.items | length,
            pods_running: ($pods.items | map(select(.status.phase == "Running")) | length),
            pods_pending: ($pods.items | map(select(.status.phase == "Pending")) | length),
            pods_failed: ($pods.items | map(select(.status.phase == "Failed")) | length)
        }')
    
    echo "$status_json"
}

# Main deployment function
deploy() {
    log "INFO" "Starting deployment of Dry Fruits Platform..."
    json_output "info" "Deployment started"
    
    check_prerequisites
    
    # Define deployment order
    local deployment_order=(
        "00-namespace-config.yaml"
        "01-infrastructure.yaml"
        "02-core-services.yaml" 
        "03-gateway-frontend.yaml"
        "services.yml"
        "infrastructure.yml"
        "platform-deployment.yaml"
    )
    
    # Apply resources in order
    local applied_files=()
    local failed_files=()
    
    for file in "${deployment_order[@]}"; do
        local file_path="$K8S_DIR/$file"
        
        if [[ -f "$file_path" ]]; then
            if apply_resource "$file_path"; then
                applied_files+=("$file")
            else
                failed_files+=("$file")
            fi
            
            # Wait a bit between applications
            sleep 2
        else
            log "WARNING" "File not found: $file_path"
        fi
    done
    
    # Apply any remaining files
    for file in "$K8S_DIR"/*.yaml "$K8S_DIR"/*.yml; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            
            # Skip if already processed
            if [[ " ${deployment_order[*]} " =~ " ${filename} " ]]; then
                continue
            fi
            
            if apply_resource "$file"; then
                applied_files+=("$filename")
            else
                failed_files+=("$filename")
            fi
            
            sleep 1
        fi
    done
    
    log "INFO" "Deployment phase completed. Applied: ${#applied_files[@]}, Failed: ${#failed_files[@]}"
    
    # Wait for pods if not dry run
    if [[ "$DRY_RUN" != "true" && ${#applied_files[@]} -gt 0 ]]; then
        local project_name
        project_name=$(oc project -q 2>/dev/null || echo "dry-fruits-platform")
        
        wait_for_pods "$project_name" 300
        
        # Get final status
        local final_status
        final_status=$(get_deployment_status "$project_name")
        
        log "INFO" "Deployment completed!"
        log "INFO" "Final status: $final_status"
        
        json_output "success" "Deployment completed" "$final_status"
        
        # Show useful commands
        log "INFO" "Useful commands:"
        log "INFO" "  oc get pods"
        log "INFO" "  oc get routes"
        log "INFO" "  oc logs -f deployment/<service-name>"
    fi
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log "ERROR" "Some files failed to deploy: ${failed_files[*]}"
        exit 1
    fi
}

# Handle script arguments
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run       Show what would be deployed without actually doing it"
    echo "  --json          Output JSON status messages"
    echo "  --verbose       Enable verbose logging"
    echo "  --force         Continue even if some resources fail"
    echo "  --help          Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  DRY_RUN         Same as --dry-run"
    echo "  JSON_OUTPUT     Same as --json"
    echo "  VERBOSE         Same as --verbose"
    echo "  FORCE           Same as --force"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --json)
            JSON_OUTPUT="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --force)
            FORCE="true"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Trap for cleanup
trap 'log "ERROR" "Script interrupted"' INT TERM

# Run deployment
deploy