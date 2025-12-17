#!/bin/bash
# Enhanced OpenShift Login Script - Cross Platform Bash Version
# This script works with both interactive and automated environments

set -euo pipefail

# Configuration (can be overridden by environment variables)
API_URL="${OCP_API_URL:-https://api.lab02.ocp4.wfocplab.wwtatc.com:6443}"
USERNAME="${OCP_USERNAME:-kubeadmin}"
PASSWORD="${OCP_PASSWORD:-VMAPE-NXSVe-MUb7I-Eghpc}"
PROJECT="${OCP_PROJECT:-dry-fruits-platform}"

# Script options
SILENT="${SILENT:-false}"
JSON_OUTPUT="${JSON_OUTPUT:-false}"

# Colors for output (if supported)
if [[ -t 1 ]] && command -v tput &> /dev/null; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    MAGENTA=$(tput setaf 5)
    GRAY=$(tput setaf 8)
    NC=$(tput sgr0)
else
    RED='' GREEN='' YELLOW='' CYAN='' MAGENTA='' GRAY='' NC=''
fi

# Function to write colored output
write_color_output() {
    local message="$1"
    local color="${2:-$NC}"
    if [[ "$SILENT" != "true" ]]; then
        echo -e "${color}${message}${NC}"
    fi
}

# Function to output JSON status (for agent consumption)
write_json_status() {
    local status="$1"
    local message="$2"
    local data="${3:-{}}"
    
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        local timestamp
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "{\"status\":\"$status\",\"message\":\"$message\",\"timestamp\":\"$timestamp\",\"data\":$data}"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Main execution
main() {
    write_color_output "🔐 Logging into OpenShift Cluster..." "$CYAN"
    write_color_output "API URL: $API_URL" "$YELLOW"
    write_color_output "Username: $USERNAME" "$YELLOW"
    
    write_json_status "info" "Starting OpenShift login" "{\"apiUrl\":\"$API_URL\",\"username\":\"$USERNAME\",\"project\":\"$PROJECT\"}"

    # Check if oc CLI is available
    if ! command_exists oc; then
        local error_msg="OpenShift CLI (oc) not found. Please install OpenShift CLI first."
        write_color_output "❌ $error_msg" "$RED"
        write_json_status "error" "$error_msg"
        exit 1
    fi

    # Create temporary files for output capture
    local login_output
    local login_error
    login_output=$(mktemp)
    login_error=$(mktemp)
    
    # Cleanup function
    cleanup() {
        rm -f "$login_output" "$login_error"
    }
    trap cleanup EXIT

    # Login to OpenShift
    if oc login "$API_URL" -u "$USERNAME" -p "$PASSWORD" > "$login_output" 2> "$login_error"; then
        write_color_output "✅ Login successful!" "$GREEN"
        write_json_status "success" "Login successful"
        
        # Check if project exists
        if oc get project "$PROJECT" &>/dev/null; then
            write_color_output "📂 Switching to project: $PROJECT" "$YELLOW"
            oc project "$PROJECT"
            write_json_status "info" "Switched to existing project" "{\"project\":\"$PROJECT\"}"
        else
            write_color_output "🆕 Project '$PROJECT' not found. Creating..." "$MAGENTA"
            oc new-project "$PROJECT" --description="Dry Fruits Microservices Platform"
            write_json_status "info" "Created new project" "{\"project\":\"$PROJECT\"}"
        fi
        
        # Get current context info
        local server
        local current_project
        server=$(oc whoami --show-server)
        current_project=$(oc project -q)
        
        write_color_output "🚀 Ready to deploy!" "$GREEN"
        write_color_output "Current context:" "$CYAN"
        write_color_output "Server: $server" "$GRAY"
        write_color_output "Project: $current_project" "$GRAY"
        
        write_json_status "success" "Ready to deploy" "{\"server\":\"$server\",\"currentProject\":\"$current_project\",\"readyToDeploy\":true}"
        
        write_color_output "\n🎯 You can now deploy your microservices!" "$GREEN"
        write_color_output "Example commands:" "$GRAY"
        write_color_output "  oc apply -f k8s/" "$GRAY"
        write_color_output "  oc get pods" "$GRAY"
        write_color_output "  oc get routes" "$GRAY"
        
        # Export environment variables for other scripts
        export OCP_SERVER="$server"
        export OCP_PROJECT="$current_project"
        export OCP_LOGGED_IN="true"
        
        # Save to .env file for persistence
        {
            echo "export OCP_SERVER=\"$server\""
            echo "export OCP_PROJECT=\"$current_project\""
            echo "export OCP_LOGGED_IN=\"true\""
            echo "export OCP_API_URL=\"$API_URL\""
        } > .env.ocp
        
    else
        local error_content
        error_content=$(cat "$login_error")
        local error_msg="Login failed: $error_content"
        write_color_output "❌ $error_msg" "$RED"
        write_json_status "error" "$error_msg"
        exit 1
    fi

    # Return success for agent consumption
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        write_json_status "complete" "Login process completed successfully"
    fi
}

# Handle script arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --silent)
            SILENT="true"
            shift
            ;;
        --json)
            JSON_OUTPUT="true"
            shift
            ;;
        --api-url)
            API_URL="$2"
            shift 2
            ;;
        --username)
            USERNAME="$2"
            shift 2
            ;;
        --password)
            PASSWORD="$2"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --silent         Suppress output"
            echo "  --json          Output JSON status"
            echo "  --api-url URL   OpenShift API URL"
            echo "  --username USER Username"
            echo "  --password PASS Password"
            echo "  --project PROJ  Project name"
            echo "  --help          Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main