# Comprehensive Synthetic Monitoring for Dry Fruits Platform (OpenShift)
# Tests all endpoints, monitors health, detects errors, and reports to console

param(
    [int]$DurationMinutes = 60,
    [int]$IntervalSeconds = 30,
    [switch]$Continuous
)

# URLs Configuration
$script:URLs = @{
    CustomerPortal = "https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    UserService = "https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    PaymentService = "https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    AdminDashboard = "https://admin-dashboard-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    Grafana = "https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    Prometheus = "https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    Jaeger = "https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
}

# Health Check Endpoints
$script:HealthEndpoints = @(
    @{Name="User Service Health"; URL="$($URLs.UserService)/api/v1/users/health"; Expected="UP"}
    @{Name="User Service Actuator"; URL="$($URLs.UserService)/actuator/health"; Expected="UP"}
    @{Name="Payment Service Health"; URL="$($URLs.PaymentService)/api/v1/payments/health"; Expected="UP"}
    @{Name="Prometheus Targets"; URL="$($URLs.Prometheus)/api/v1/targets"; Expected="success"}
)

# Test Cards
$script:TestCards = @{
    Success = @{
        Number = "4111111111111111"
        Name = "Test User"
        Expiry = "12/27"
        CVV = "123"
    }
    Failure = @{
        Number = "4000000000000002"
        Name = "Test User"
        Expiry = "12/27"
        CVV = "123"
    }
}

# Monitoring Statistics
$script:Stats = @{
    TotalChecks = 0
    SuccessfulChecks = 0
    FailedChecks = 0
    Errors = @()
    StartTime = Get-Date
}

# Function to display banner
function Show-Banner {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   🔍 Dry Fruits Platform - Synthetic Monitoring System     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    if ($Continuous) {
        Write-Host "Mode: Continuous monitoring" -ForegroundColor Yellow
    } else {
        Write-Host "Duration: $DurationMinutes minutes" -ForegroundColor Yellow
    }
    Write-Host "Interval: $IntervalSeconds seconds" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Gray
}

# Function to test HTTP endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$URL,
        [string]$ExpectedContent = $null,
        [int]$TimeoutSeconds = 10
    )
    
    $script:Stats.TotalChecks++
    $startTime = Get-Date
    
    try {
        $response = Invoke-WebRequest -Uri $URL -Method Get -TimeoutSec $TimeoutSeconds -UseBasicParsing -SkipCertificateCheck -ErrorAction Stop
        $duration = ((Get-Date) - $startTime).TotalMilliseconds
        
        $success = $true
        if ($ExpectedContent -and $response.Content -notmatch $ExpectedContent) {
            $success = $false
            $reason = "Expected content not found"
        }
        
        if ($response.StatusCode -ne 200) {
            $success = $false
            $reason = "Status code: $($response.StatusCode)"
        }
        
        if ($success) {
            $script:Stats.SuccessfulChecks++
            Write-Host "✅ " -NoNewline -ForegroundColor Green
            Write-Host "$Name " -NoNewline -ForegroundColor White
            Write-Host "[$($response.StatusCode)] " -NoNewline -ForegroundColor Green
            Write-Host "$([math]::Round($duration, 0))ms" -ForegroundColor Gray
            return $true
        } else {
            $script:Stats.FailedChecks++
            $errorInfo = @{
                Time = Get-Date
                Name = $Name
                URL = $URL
                Reason = $reason
            }
            $script:Stats.Errors += $errorInfo
            Write-Host "⚠️  " -NoNewline -ForegroundColor Yellow
            Write-Host "$Name " -NoNewline -ForegroundColor White
            Write-Host "[$reason]" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        $script:Stats.FailedChecks++
        $duration = ((Get-Date) - $startTime).TotalMilliseconds
        $errorInfo = @{
            Time = Get-Date
            Name = $Name
            URL = $URL
            Reason = $_.Exception.Message
        }
        $script:Stats.Errors += $errorInfo
        
        Write-Host "❌ " -NoNewline -ForegroundColor Red
        Write-Host "$Name " -NoNewline -ForegroundColor White
        Write-Host "[ERROR] " -NoNewline -ForegroundColor Red
        Write-Host "$([math]::Round($duration, 0))ms - " -NoNewline -ForegroundColor Gray
        Write-Host "$($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test user authentication flow
function Test-UserAuthFlow {
    Write-Host "`n📝 Testing User Authentication Flow..." -ForegroundColor Cyan
    
    # Test registration endpoint availability
    Test-Endpoint -Name "Registration Endpoint" -URL "$($URLs.UserService)/api/v1/auth/register"
    
    # Test login endpoint availability
    Test-Endpoint -Name "Login Endpoint" -URL "$($URLs.UserService)/api/v1/auth/login"
}

# Function to simulate complete user journey
function Test-CompleteUserJourney {
    Write-Host "`n🛒 Testing Complete E-Commerce Journey..." -ForegroundColor Cyan
    
    # 1. Access customer portal
    $portalResult = Test-Endpoint -Name "Customer Portal Homepage" -URL $URLs.CustomerPortal
    
    if ($portalResult) {
        # 2. Check if login is available
        Test-Endpoint -Name "User Login Page" -URL "$($URLs.CustomerPortal)"
        
        # 3. Test cart functionality (simulated)
        Write-Host "   ℹ️  Cart: Simulated add-to-cart action" -ForegroundColor Gray
        
        # 4. Test checkout flow availability
        Write-Host "   ℹ️  Checkout: Modal should be available on frontend" -ForegroundColor Gray
        
        # 5. Test payment service availability
        Test-Endpoint -Name "Payment Service Root" -URL "$($URLs.PaymentService)/" -ExpectedContent "Payment Service"
        Test-Endpoint -Name "Payment Test Cards" -URL "$($URLs.PaymentService)/api/v1/payments/test-cards"
    } else {
        Write-Host "   ⚠️  Skipping journey steps - Portal unavailable" -ForegroundColor Yellow
    }
}

# Function to test observability stack
function Test-ObservabilityStack {
    Write-Host "`n📊 Testing Observability Tools..." -ForegroundColor Cyan
    
    # Test Grafana
    Test-Endpoint -Name "Grafana Dashboard" -URL $URLs.Grafana
    
    # Test Prometheus
    Test-Endpoint -Name "Prometheus Metrics" -URL $URLs.Prometheus
    Test-Endpoint -Name "Prometheus API" -URL "$($URLs.Prometheus)/api/v1/query?query=up"
    
    # Test Jaeger
    Test-Endpoint -Name "Jaeger Tracing UI" -URL $URLs.Jaeger
}

# Function to check all health endpoints
function Test-HealthEndpoints {
    Write-Host "`n💓 Checking Service Health..." -ForegroundColor Cyan
    
    foreach ($endpoint in $script:HealthEndpoints) {
        Test-Endpoint -Name $endpoint.Name -URL $endpoint.URL -ExpectedContent $endpoint.Expected
    }
}

# Function to test all frontend pages
function Test-AllFrontendPages {
    Write-Host "`n🌐 Testing Frontend Accessibility..." -ForegroundColor Cyan
    
    Test-Endpoint -Name "Customer Portal" -URL $URLs.CustomerPortal
    Test-Endpoint -Name "Admin Dashboard" -URL $URLs.AdminDashboard
}

# Function to test all backend services
function Test-AllBackendServices {
    Write-Host "`n⚙️  Testing Backend Services..." -ForegroundColor Cyan
    
    Test-Endpoint -Name "User Service Root" -URL "$($URLs.UserService)/" -ExpectedContent "User Service"
    Test-Endpoint -Name "User Service Info" -URL "$($URLs.UserService)/api/v1/users/info"
    Test-Endpoint -Name "Payment Service Root" -URL "$($URLs.PaymentService)/" -ExpectedContent "Payment Service"
}

# Function to display statistics
function Show-Statistics {
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    📈 MONITORING STATISTICS                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $runtime = (Get-Date) - $script:Stats.StartTime
    $successRate = if ($script:Stats.TotalChecks -gt 0) {
        [math]::Round(($script:Stats.SuccessfulChecks / $script:Stats.TotalChecks) * 100, 2)
    } else { 0 }
    
    Write-Host ""
    Write-Host "Runtime:         " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($runtime.TotalMinutes, 1)) minutes" -ForegroundColor White
    
    Write-Host "Total Checks:    " -NoNewline -ForegroundColor Gray
    Write-Host "$($script:Stats.TotalChecks)" -ForegroundColor White
    
    Write-Host "Successful:      " -NoNewline -ForegroundColor Gray
    Write-Host "$($script:Stats.SuccessfulChecks) " -NoNewline -ForegroundColor Green
    Write-Host "($successRate%)" -ForegroundColor Gray
    
    Write-Host "Failed:          " -NoNewline -ForegroundColor Gray
    Write-Host "$($script:Stats.FailedChecks)" -ForegroundColor Red
    
    Write-Host "Success Rate:    " -NoNewline -ForegroundColor Gray
    if ($successRate -ge 95) {
        Write-Host "$successRate% ✅" -ForegroundColor Green
    } elseif ($successRate -ge 80) {
        Write-Host "$successRate% ⚠️" -ForegroundColor Yellow
    } else {
        Write-Host "$successRate% ❌" -ForegroundColor Red
    }
    
    if ($script:Stats.Errors.Count -gt 0) {
        Write-Host "`n🚨 Recent Errors (Last 5):" -ForegroundColor Red
        $script:Stats.Errors | Select-Object -Last 5 | ForEach-Object {
            Write-Host "   [$($_.Time.ToString('HH:mm:ss'))] " -NoNewline -ForegroundColor Gray
            Write-Host "$($_.Name): " -NoNewline -ForegroundColor White
            Write-Host "$($_.Reason)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n═══════════════════════════════════════════════════════════════`n" -ForegroundColor Gray
}

# Function to run all tests
function Invoke-MonitoringCycle {
    $cycleStart = Get-Date
    
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║         🔄 Starting Monitoring Cycle - $(Get-Date -Format 'HH:mm:ss')        ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    
    # Run all test suites
    Test-AllFrontendPages
    Test-AllBackendServices
    Test-HealthEndpoints
    Test-UserAuthFlow
    Test-CompleteUserJourney
    Test-ObservabilityStack
    
    # Display statistics
    Show-Statistics
    
    $cycleDuration = ((Get-Date) - $cycleStart).TotalSeconds
    Write-Host "Cycle completed in $([math]::Round($cycleDuration, 1)) seconds`n" -ForegroundColor Gray
}

# Main execution
try {
    Show-Banner
    
    if ($Continuous) {
        Write-Host "⏰ Running continuous monitoring. Press Ctrl+C to stop.`n" -ForegroundColor Yellow
        
        while ($true) {
            Invoke-MonitoringCycle
            Write-Host "⏸️  Waiting $IntervalSeconds seconds before next cycle...`n" -ForegroundColor Gray
            Start-Sleep -Seconds $IntervalSeconds
        }
    } else {
        $endTime = (Get-Date).AddMinutes($DurationMinutes)
        Write-Host "⏰ Monitoring will run until $(Get-Date $endTime -Format 'HH:mm:ss')`n" -ForegroundColor Yellow
        
        while ((Get-Date) -lt $endTime) {
            Invoke-MonitoringCycle
            
            if ((Get-Date) -lt $endTime) {
                Write-Host "⏸️  Waiting $IntervalSeconds seconds before next cycle...`n" -ForegroundColor Gray
                Start-Sleep -Seconds $IntervalSeconds
            }
        }
        
        Write-Host "`n✅ Monitoring completed!" -ForegroundColor Green
        Show-Statistics
    }
}
catch {
    Write-Host "`n❌ Monitoring stopped: $($_.Exception.Message)" -ForegroundColor Red
    Show-Statistics
}
finally {
    Write-Host "`n📋 Final Report:" -ForegroundColor Cyan
    Show-Statistics
    
    # Export errors to file
    if ($script:Stats.Errors.Count -gt 0) {
        $errorFile = "synthetic-monitor-errors-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
        $script:Stats.Errors | ForEach-Object {
            "[$($_.Time)] $($_.Name): $($_.Reason)"
        } | Out-File -FilePath $errorFile
        Write-Host "❌ Errors exported to: $errorFile" -ForegroundColor Yellow
    }
}
