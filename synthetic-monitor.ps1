# PowerShell Synthetic Monitoring Script for Windows
# Dry Fruits Platform Load Testing and Monitoring

Write-Host "🚀 Starting Synthetic Monitoring for Dry Fruits Platform..." -ForegroundColor Green

# Configuration
$CustomerPortal = "http://localhost:30900"
$AdminDashboard = "http://localhost:8080"
$InventoryAPI = "http://localhost:8084"
$ShippingAPI = "http://localhost:8085"
$EurekaServer = "http://localhost:8762"
$GrafanaURL = "http://localhost:3000"
$PrometheusURL = "http://localhost:9091"
$JaegerURL = "http://localhost:16686"

# Test users and products
$Users = @("john_doe", "jane_smith", "mike_wilson", "sarah_johnson", "david_brown", "admin_user")
$Products = @("almonds", "cashews", "walnuts", "pistachios", "dried_dates", "raisins")

# Function to generate HTTP requests
function Invoke-SyntheticRequest {
    param(
        [string]$Url,
        [string]$UserAgent = "SyntheticMonitor/1.0",
        [string]$RequestId = "synthetic-$(Get-Date -Format 'yyyyMMddHHmmss')"
    )
    
    try {
        $headers = @{
            'User-Agent' = $UserAgent
            'X-Request-ID' = $RequestId
        }
        
        $response = Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 30
        Write-Host "✅ $Url - Status: $($response.StatusCode)" -ForegroundColor Green
        return $response.StatusCode
    }
    catch {
        Write-Host "❌ $Url - Error: $($_.Exception.Message)" -ForegroundColor Red
        return 0
    }
}

# Function to simulate user journey
function Start-UserJourney {
    param([string]$Username)
    
    Write-Host "👤 Starting user journey for: $Username" -ForegroundColor Cyan
    $sessionId = "session-$Username-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    # 1. Visit homepage
    Invoke-SyntheticRequest -Url $CustomerPortal -UserAgent "User-$Username" -RequestId $sessionId
    Start-Sleep -Milliseconds 500
    
    # 2. Check services health
    Invoke-SyntheticRequest -Url "$InventoryAPI/actuator/health" -UserAgent "User-$Username"
    Invoke-SyntheticRequest -Url "$ShippingAPI/actuator/health" -UserAgent "User-$Username"
    Start-Sleep -Milliseconds 300
    
    # 3. Browse products (simulate API calls)
    foreach ($product in $Products) {
        Invoke-SyntheticRequest -Url "$InventoryAPI/api/inventory/search?product=$product" -UserAgent "User-$Username"
        Start-Sleep -Milliseconds 200
    }
    
    # 4. Admin operations
    if ($Username -eq "admin_user") {
        Invoke-SyntheticRequest -Url $AdminDashboard -UserAgent "Admin-$Username"
        Invoke-SyntheticRequest -Url "$EurekaServer/eureka/apps" -UserAgent "Admin-$Username"
    }
    
    Write-Host "✅ User journey completed for: $Username" -ForegroundColor Green
}

# Function to generate load burst
function Start-LoadBurst {
    Write-Host "📈 Generating load burst..." -ForegroundColor Yellow
    
    $endpoints = @(
        @{Url=$CustomerPortal; Name="Customer Portal"},
        @{Url=$AdminDashboard; Name="Admin Dashboard"},
        @{Url="$InventoryAPI/actuator/health"; Name="Inventory Health"},
        @{Url="$ShippingAPI/actuator/health"; Name="Shipping Health"},
        @{Url="$EurekaServer/eureka/apps"; Name="Eureka Registry"}
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "🎯 Testing $($endpoint.Name)..." -ForegroundColor Magenta
        
        # Generate 15 requests per endpoint
        1..15 | ForEach-Object {
            Start-Job -ScriptBlock {
                param($url, $id)
                try {
                    Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 | Out-Null
                } catch { }
            } -ArgumentList $endpoint.Url, $_
            Start-Sleep -Milliseconds 100
        }
    }
    
    # Wait for jobs to complete (max 30 seconds)
    Get-Job | Wait-Job -Timeout 30 | Out-Null
    Get-Job | Remove-Job -Force
}

# Function to check observability stack
function Test-ObservabilityStack {
    Write-Host "🔍 Testing Observability Stack..." -ForegroundColor Blue
    
    $services = @(
        @{Name="Grafana Dashboard"; Url=$GrafanaURL},
        @{Name="Prometheus Metrics"; Url=$PrometheusURL},
        @{Name="Jaeger Tracing"; Url=$JaegerURL}
    )
    
    foreach ($service in $services) {
        $status = Invoke-SyntheticRequest -Url $service.Url
        if ($status -eq 200) {
            Write-Host "✅ $($service.Name) is accessible" -ForegroundColor Green
        } else {
            Write-Host "❌ $($service.Name) is not accessible" -ForegroundColor Red
        }
    }
}

# Main execution
Write-Host "🎯 Starting Comprehensive Load Testing..." -ForegroundColor Yellow

# 1. Test observability stack first
Test-ObservabilityStack

# 2. Generate initial load burst
Start-LoadBurst

# 3. Simulate realistic user journeys
Write-Host "🚶 Simulating user journeys..." -ForegroundColor Cyan
foreach ($user in $Users) {
    Start-Job -ScriptBlock {
        param($u, $cp, $ad, $inv, $ship, $eur, $products)
        
        function Invoke-Request($url) {
            try { 
                Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 | Out-Null
                return $true
            } catch { 
                return $false 
            }
        }
        
        # User journey
        Invoke-Request $cp
        Start-Sleep -Milliseconds 500
        Invoke-Request "$inv/actuator/health"
        Invoke-Request "$ship/actuator/health"
        
        foreach ($p in $products) {
            Invoke-Request "$inv/api/inventory/search?product=$p"
            Start-Sleep -Milliseconds 300
        }
        
        if ($u -eq "admin_user") {
            Invoke-Request $ad
            Invoke-Request "$eur/eureka/apps"
        }
        
    } -ArgumentList $user, $CustomerPortal, $AdminDashboard, $InventoryAPI, $ShippingAPI, $EurekaServer, $Products
    
    Start-Sleep -Milliseconds 500
}

# Wait for all user journeys to complete
Write-Host "⏳ Waiting for user journeys to complete..." -ForegroundColor Yellow
Get-Job | Wait-Job -Timeout 60 | Out-Null
Get-Job | Remove-Job -Force

# 4. Generate metrics queries to Prometheus
Write-Host "📊 Generating metrics queries..." -ForegroundColor Magenta
$metricsQueries = @(
    "up",
    "http_server_requests_seconds_count",
    "jvm_memory_used_bytes",
    "system_cpu_usage",
    "hikaricp_connections_active"
)

foreach ($query in $metricsQueries) {
    try {
        Invoke-WebRequest -Uri "$PrometheusURL/api/v1/query?query=$query" -UseBasicParsing | Out-Null
        Write-Host "✅ Prometheus query: $query" -ForegroundColor Green
    } catch {
        Write-Host "❌ Prometheus query failed: $query" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 200
}

# 5. Final status report
Write-Host "`n🎉 Synthetic Monitoring Completed!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

Write-Host "📊 Access your monitoring dashboards:" -ForegroundColor Cyan
Write-Host "   • Grafana Dashboard: $GrafanaURL (admin/grafana123)" -ForegroundColor White
Write-Host "   • Prometheus Metrics: $PrometheusURL" -ForegroundColor White  
Write-Host "   • Jaeger Tracing: $JaegerURL" -ForegroundColor White

Write-Host "`n🎯 Application URLs:" -ForegroundColor Cyan
Write-Host "   • Customer Portal: $CustomerPortal" -ForegroundColor White
Write-Host "   • Admin Dashboard: $AdminDashboard" -ForegroundColor White

Write-Host "`n⚡ Load Testing Summary:" -ForegroundColor Cyan
Write-Host "   • Generated requests to all services" -ForegroundColor White
Write-Host "   • Simulated $($Users.Count) user journeys" -ForegroundColor White
Write-Host "   • Tested $($Products.Count) product searches" -ForegroundColor White
Write-Host "   • Load burst with multiple concurrent requests" -ForegroundColor White

Write-Host "`n🔍 Check Grafana for metrics and dashboards now!" -ForegroundColor Green