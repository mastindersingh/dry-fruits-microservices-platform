# PowerShell Environment Setup for Dry Fruits Platform
# Import this module to set up your PowerShell environment

# OpenShift Configuration
$env:OCP_API_URL = "https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"
$env:OCP_USERNAME = "kubeadmin"
$env:OCP_PROJECT = "dry-fruits-platform"

# Script Configuration
$ScriptRoot = Split-Path -Parent $PSCommandPath
$ProjectRoot = Split-Path -Parent $ScriptRoot
$env:PROJECT_ROOT = $ProjectRoot
$env:SCRIPTS_DIR = "$ProjectRoot\scripts"

# Add scripts to PATH if not already there
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Process")
if ($currentPath -notlike "*$env:SCRIPTS_DIR*") {
    $env:PATH = "$env:SCRIPTS_DIR;$currentPath"
}

# Function aliases for common operations
function Invoke-OCPLogin {
    [CmdletBinding()]
    param(
        [switch]$Json,
        [switch]$Silent,
        [string]$ApiUrl,
        [string]$Username,
        [string]$Project
    )
    
    $params = @()
    if ($Json) { $params += "--json" }
    if ($Silent) { $params += "--silent" }
    if ($ApiUrl) { $params += "--api-url", $ApiUrl }
    if ($Username) { $params += "--username", $Username }
    if ($Project) { $params += "--project", $Project }
    
    & "$env:SCRIPTS_DIR\ocp-login-enhanced.ps1" @params
}

function Invoke-OCPDeploy {
    [CmdletBinding()]
    param(
        [switch]$DryRun,
        [switch]$Json,
        [switch]$Verbose,
        [switch]$Force
    )
    
    $bashParams = @()
    if ($DryRun) { $bashParams += "--dry-run" }
    if ($Json) { $bashParams += "--json" }
    if ($Verbose) { $bashParams += "--verbose" }
    if ($Force) { $bashParams += "--force" }
    
    # Try to run bash script if available, otherwise use PowerShell equivalent
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        bash "$ProjectRoot\scripts\deploy-platform.sh" @bashParams
    } else {
        Write-Warning "Bash not available. Using PowerShell deployment (limited functionality)"
        # Fallback PowerShell deployment logic would go here
        oc apply -f "$ProjectRoot\k8s\"
    }
}

function Get-OCPStatus {
    [CmdletBinding()]
    param(
        [string]$Namespace = "dry-fruits-platform",
        [switch]$Json
    )
    
    if ($Json) {
        oc get pods,svc,routes -n $Namespace -o json | ConvertFrom-Json
    } else {
        oc get pods,svc,routes -n $Namespace
    }
}

function Get-OCPLogs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Resource,
        [switch]$Follow,
        [string]$Namespace = "dry-fruits-platform"
    )
    
    $params = @("logs", $Resource, "-n", $Namespace)
    if ($Follow) { $params += "-f" }
    
    & oc @params
}

# Create aliases
Set-Alias -Name ocp-login -Value Invoke-OCPLogin
Set-Alias -Name ocp-deploy -Value Invoke-OCPDeploy
Set-Alias -Name ocp-status -Value Get-OCPStatus
Set-Alias -Name ocp-logs -Value Get-OCPLogs

# Tab completion for OpenShift
if (Get-Command oc -ErrorAction SilentlyContinue) {
    # Register argument completers for oc command
    Register-ArgumentCompleter -CommandName oc -ScriptBlock {
        param($commandName, $commandAst, $cursorPosition)
        
        # Basic completion for common oc commands
        $commands = @('apply', 'get', 'delete', 'logs', 'describe', 'create', 'project', 'login', 'logout')
        $resources = @('pods', 'services', 'routes', 'deployments', 'configmaps', 'secrets')
        
        $line = $commandAst.ToString()
        $tokens = $line.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
        
        if ($tokens.Length -eq 2) {
            # Complete subcommands
            $commands | Where-Object { $_ -like "$($tokens[1])*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        } elseif ($tokens.Length -eq 3 -and $tokens[1] -in @('get', 'describe', 'delete')) {
            # Complete resource types
            $resources | Where-Object { $_ -like "$($tokens[2])*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

# Welcome message
Write-Host "🌟 Dry Fruits Platform PowerShell Environment Loaded!" -ForegroundColor Green
Write-Host "📁 Project Root: $ProjectRoot" -ForegroundColor Cyan
Write-Host "🔧 Scripts Dir: $env:SCRIPTS_DIR" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  ocp-login     - Login to OpenShift" -ForegroundColor Gray
Write-Host "  ocp-deploy    - Deploy the platform" -ForegroundColor Gray
Write-Host "  ocp-status    - Check deployment status" -ForegroundColor Gray
Write-Host "  ocp-logs      - View logs" -ForegroundColor Gray
Write-Host ""
Write-Host "For agent/JSON output, use:" -ForegroundColor Yellow
Write-Host "  ocp-login -Json" -ForegroundColor Gray
Write-Host "  ocp-deploy -Json -Verbose" -ForegroundColor Gray
Write-Host "  ocp-status -Json" -ForegroundColor Gray

# Export functions for external use
Export-ModuleMember -Function @(
    'Invoke-OCPLogin',
    'Invoke-OCPDeploy', 
    'Get-OCPStatus',
    'Get-OCPLogs'
) -Alias @(
    'ocp-login',
    'ocp-deploy',
    'ocp-status', 
    'ocp-logs'
)