# Enhanced OpenShift Login Script for Agent/Bash Compatibility
# This script works with both interactive and automated environments

param(
    [string]$ApiUrl = "https://api.lab02.ocp4.wfocplab.wwtatc.com:6443",
    [string]$Username = "kubeadmin",
    [string]$Password = "VMAPE-NXSVe-MUb7I-Eghpc",
    [string]$Project = "dry-fruits-platform",
    [switch]$Silent = $false,
    [switch]$JsonOutput = $false
)

# Function to write colored output
function Write-ColorOutput {
    param($Message, $Color = "White")
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Function to output JSON status (for agent consumption)
function Write-JsonStatus {
    param($Status, $Message, $Data = @{})
    if ($JsonOutput) {
        $output = @{
            status = $Status
            message = $Message
            timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            data = $Data
        } | ConvertTo-Json -Compress
        Write-Output $output
    }
}

try {
    Write-ColorOutput "🔐 Logging into OpenShift Cluster..." "Cyan"
    Write-ColorOutput "API URL: $ApiUrl" "Yellow"
    Write-ColorOutput "Username: $Username" "Yellow"
    
    Write-JsonStatus "info" "Starting OpenShift login" @{
        apiUrl = $ApiUrl
        username = $Username
        project = $Project
    }

    # Check if oc CLI is available
    $ocPath = Get-Command oc -ErrorAction SilentlyContinue
    if (-not $ocPath) {
        $errorMsg = "OpenShift CLI (oc) not found. Please install OpenShift CLI first."
        Write-ColorOutput "❌ $errorMsg" "Red"
        Write-JsonStatus "error" $errorMsg
        exit 1
    }

    # Login to OpenShift
    $loginArgs = @("login", $ApiUrl, "-u", $Username, "-p", $Password)
    $loginProcess = Start-Process -FilePath "oc" -ArgumentList $loginArgs -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "login-output.tmp" -RedirectStandardError "login-error.tmp"
    
    if ($loginProcess.ExitCode -eq 0) {
        Write-ColorOutput "✅ Login successful!" "Green"
        Write-JsonStatus "success" "Login successful"
        
        # Check if project exists
        $projectCheck = & oc get project $Project 2>$null
        $projectExists = $LASTEXITCODE -eq 0
        
        if ($projectExists) {
            Write-ColorOutput "📂 Switching to project: $Project" "Yellow"
            & oc project $Project
            Write-JsonStatus "info" "Switched to existing project" @{project = $Project}
        } else {
            Write-ColorOutput "🆕 Project '$Project' not found. Creating..." "Magenta"
            & oc new-project $Project --description="Dry Fruits Microservices Platform"
            Write-JsonStatus "info" "Created new project" @{project = $Project}
        }
        
        # Get current context info
        $server = & oc whoami --show-server
        $currentProject = & oc project -q
        
        Write-ColorOutput "🚀 Ready to deploy!" "Green"
        Write-ColorOutput "Current context:" "Cyan"
        Write-ColorOutput "Server: $server" "Gray"
        Write-ColorOutput "Project: $currentProject" "Gray"
        
        Write-JsonStatus "success" "Ready to deploy" @{
            server = $server
            currentProject = $currentProject
            readyToDeploy = $true
        }
        
        Write-ColorOutput "`n🎯 You can now deploy your microservices!" "Green"
        Write-ColorOutput "Example commands:" "Gray"
        Write-ColorOutput "  oc apply -f k8s/" "Gray"
        Write-ColorOutput "  oc get pods" "Gray"
        Write-ColorOutput "  oc get routes" "Gray"
        
        # Export environment variables for other scripts
        $env:OCP_SERVER = $server
        $env:OCP_PROJECT = $currentProject
        $env:OCP_LOGGED_IN = "true"
        
    } else {
        $errorContent = Get-Content "login-error.tmp" -ErrorAction SilentlyContinue
        $errorMsg = "Login failed: $errorContent"
        Write-ColorOutput "❌ $errorMsg" "Red"
        Write-JsonStatus "error" $errorMsg
        exit 1
    }

} catch {
    $errorMsg = "Error during login: $($_.Exception.Message)"
    Write-ColorOutput "💥 $errorMsg" "Red"
    Write-JsonStatus "error" $errorMsg
    exit 1
} finally {
    # Cleanup temp files
    Remove-Item "login-output.tmp", "login-error.tmp" -ErrorAction SilentlyContinue
}

# Return success for agent consumption
if ($JsonOutput) {
    Write-JsonStatus "complete" "Login process completed successfully"
}