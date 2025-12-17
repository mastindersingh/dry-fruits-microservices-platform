#!/bin/bash
# Quick Setup Script for Agent-Friendly Environment
# This script sets up the environment for both bash and PowerShell

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Setting up Dry Fruits Platform Environment..."

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

# Check available environments
HAS_BASH=false
HAS_POWERSHELL=false
HAS_WSL=false

if command -v bash &> /dev/null; then
    HAS_BASH=true
fi

if command -v pwsh &> /dev/null || command -v powershell &> /dev/null; then
    HAS_POWERSHELL=true
fi

if command -v wsl &> /dev/null; then
    HAS_WSL=true
fi

echo "📊 Environment Check:"
echo "  Bash available: $HAS_BASH"
echo "  PowerShell available: $HAS_POWERSHELL" 
echo "  WSL available: $HAS_WSL"

# Install Git Bash if on Windows and bash not available
if [[ "$OSTYPE" =~ ^msys ]] || [[ "$OSTYPE" =~ ^win ]] || [[ -n "$WINDIR" ]]; then
    if ! $HAS_BASH; then
        echo "⚠️  Bash not found on Windows. Consider installing:"
        echo "   • Git Bash: https://git-scm.com/download/win"
        echo "   • WSL: wsl --install"
    fi
fi

# Create convenience scripts
echo "📝 Creating convenience scripts..."

# Create PowerShell profile setup
cat > "$PROJECT_ROOT/setup-powershell.ps1" << 'EOF'
# PowerShell Environment Setup
$ScriptsPath = Join-Path $PSScriptRoot "scripts"
Import-Module "$ScriptsPath\DryFruitsPlatform.psm1" -Force

Write-Host "✅ PowerShell environment ready!" -ForegroundColor Green
Write-Host "Try: ocp-login -Json" -ForegroundColor Cyan
EOF

# Create bash profile setup
cat > "$PROJECT_ROOT/setup-bash.sh" << 'EOF'
#!/bin/bash
# Bash Environment Setup
source "$(dirname "$0")/.env.bash"

echo "✅ Bash environment ready!"
echo "Try: ocp-login --json"
EOF

chmod +x "$PROJECT_ROOT/setup-bash.sh"

# Create unified runner script
cat > "$PROJECT_ROOT/run-agent-friendly.sh" << 'EOF'
#!/bin/bash
# Unified Agent-Friendly Runner
# This script automatically detects the environment and runs commands appropriately

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Function to run command in best available environment
run_command() {
    local cmd="$1"
    shift
    local args=("$@")
    
    case "$cmd" in
        "login")
            if command -v bash &> /dev/null; then
                bash "$SCRIPT_DIR/scripts/ocp-login.sh" "${args[@]}"
            elif command -v pwsh &> /dev/null; then
                pwsh -File "$SCRIPT_DIR/scripts/ocp-login-enhanced.ps1" "${args[@]}"
            else
                echo "❌ No compatible shell found"
                exit 1
            fi
            ;;
        "deploy")
            if command -v bash &> /dev/null; then
                bash "$SCRIPT_DIR/scripts/deploy-platform.sh" "${args[@]}"
            else
                echo "❌ Deployment requires bash environment"
                echo "💡 Install Git Bash or WSL"
                exit 1
            fi
            ;;
        "status")
            oc get pods,svc,routes "${args[@]}"
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Available: login, deploy, status"
            exit 1
            ;;
    esac
}

# Parse arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <command> [args...]"
    echo "Commands: login, deploy, status"
    exit 1
fi

run_command "$@"
EOF

chmod +x "$PROJECT_ROOT/run-agent-friendly.sh"

echo "✅ Setup complete!"
echo ""
echo "🎯 Quick Start Guide:"
echo ""

if $HAS_BASH; then
    echo "For Bash users:"
    echo "  source ./setup-bash.sh"
    echo "  ocp-login --json"
    echo "  ocp-deploy --json --verbose"
    echo ""
fi

if $HAS_POWERSHELL; then
    echo "For PowerShell users:"
    echo "  . ./setup-powershell.ps1"
    echo "  ocp-login -Json"
    echo "  ocp-deploy -Json"
    echo ""
fi

echo "For Agent/Universal use:"
echo "  ./run-agent-friendly.sh login --json"
echo "  ./run-agent-friendly.sh deploy --json --verbose"
echo "  ./run-agent-friendly.sh status"
echo ""

echo "🔧 Available files created:"
echo "  📄 setup-bash.sh - Bash environment setup"
echo "  📄 setup-powershell.ps1 - PowerShell environment setup" 
echo "  📄 run-agent-friendly.sh - Universal command runner"
echo "  📄 scripts/ocp-login.sh - Enhanced bash login"
echo "  📄 scripts/ocp-login-enhanced.ps1 - PowerShell login"
echo "  📄 scripts/deploy-platform.sh - Automated deployment"
echo "  📄 scripts/DryFruitsPlatform.psm1 - PowerShell module"
echo ""

echo "🎉 Ready to use with both interactive and automated environments!"