#requires -Version 5.1
<#
Logs into OpenShift and switches to a project.
- Prompts securely for password (no hard-coded secrets).
- Optionally uses OPENSHIFT_PASSWORD env var if already set.
#>

$ErrorActionPreference = "Stop"

$API_URL  = "https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"
$USERNAME = "kubeadmin"
$PROJECT  = "dry-fruits-platform"

Write-Host "Logging into OpenShift..." -ForegroundColor Cyan
Write-Host "API: $API_URL" -ForegroundColor Yellow
Write-Host "User: $USERNAME" -ForegroundColor Yellow

# Get password from env var or prompt securely
$passwordPlain = $env:OPENSHIFT_PASSWORD
if ([string]::IsNullOrWhiteSpace($passwordPlain)) {
    $secure = Read-Host -Prompt "OpenShift Password for $USERNAME" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

# Login
# Added --insecure-skip-tls-verify to handle lab certificates
& oc login $API_URL -u $USERNAME -p $passwordPlain --insecure-skip-tls-verify=true
if ($LASTEXITCODE -ne 0) { throw "oc login failed." }

Write-Host "Login successful." -ForegroundColor Green

# Switch project (or create if missing)
& oc get project $PROJECT *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Switching to project: $PROJECT" -ForegroundColor Yellow
    & oc project $PROJECT
} else {
    Write-Host "Project not found. Creating: $PROJECT" -ForegroundColor Magenta
    & oc new-project $PROJECT --description="Dry Fruits Microservices Platform"
}

Write-Host "Current context:" -ForegroundColor Cyan
& oc whoami --show-server
& oc project
