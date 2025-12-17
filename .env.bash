# Environment setup for Dry Fruits Platform
# Source this file to set up your shell environment

# OpenShift Configuration
export OCP_API_URL="https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"
export OCP_USERNAME="kubeadmin"
export OCP_PROJECT="dry-fruits-platform"

# Script Configuration
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Add scripts to PATH
export PATH="$SCRIPT_DIR:$PATH"

# Aliases for common commands
alias ocp-login='bash $SCRIPT_DIR/ocp-login.sh'
alias ocp-deploy='bash $SCRIPT_DIR/deploy-platform.sh'
alias ocp-status='oc get pods,svc,routes'
alias ocp-logs='oc logs -f'
alias ocp-shell='oc rsh'

# Functions for agent interaction
ocp_login_json() {
    bash "$SCRIPT_DIR/ocp-login.sh" --json "$@"
}

ocp_deploy_json() {
    bash "$SCRIPT_DIR/deploy-platform.sh" --json "$@"
}

ocp_status_json() {
    local namespace="${1:-dry-fruits-platform}"
    oc get pods,svc,routes -n "$namespace" -o json
}

# Auto-completion setup
if command -v oc &> /dev/null; then
    source <(oc completion bash 2>/dev/null || true)
fi

# Welcome message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🌟 Dry Fruits Platform Environment Loaded!"
    echo "📁 Project Root: $PROJECT_ROOT"
    echo "🔧 Scripts Dir: $SCRIPT_DIR"
    echo ""
    echo "Available commands:"
    echo "  ocp-login     - Login to OpenShift"
    echo "  ocp-deploy    - Deploy the platform"
    echo "  ocp-status    - Check deployment status"
    echo "  ocp-logs      - View logs"
    echo ""
    echo "For agent/JSON output, use:"
    echo "  ocp_login_json --json"
    echo "  ocp_deploy_json --json --verbose"
    echo "  ocp_status_json"
fi