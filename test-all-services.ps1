# Test All Services - Dry Fruits Platform
# Run this to check if all services are accessible

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing All Services" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test URLs
$urls = @{
    "Customer Portal" = "https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
    "User Service Health" = "https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health"
    "Payment Service Root" = "https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/"
    "Payment Service Health" = "https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health"
    "Admin Dashboard" = "https://admin-dashboard-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"
}

foreach ($name in $urls.Keys) {
    $url = $urls[$name]
    Write-Host "Testing: $name" -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    
    try {
        # Use Invoke-WebRequest with certificate bypass
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 10 -UseBasicParsing -SkipCertificateCheck -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ SUCCESS - Status: $($response.StatusCode)" -ForegroundColor Green
            
            # Show first 200 chars of content
            $content = $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length))
            Write-Host "   Response: $content..." -ForegroundColor Gray
        } else {
            Write-Host "⚠️  WARNING - Status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Check if it's a certificate error
        if ($_.Exception.Message -like "*certificate*" -or $_.Exception.Message -like "*SSL*") {
            Write-Host "   💡 This might be a certificate issue. Open the URL in browser and accept the certificate." -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Pod Status Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check pod status
Write-Host "Checking OpenShift pods..." -ForegroundColor Yellow
$podStatus = oc get pods -n dry-fruits-platform -o wide 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host $podStatus
} else {
    Write-Host "❌ Unable to check pods. Are you logged into OpenShift?" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Common Issues & Solutions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1. Certificate Errors:" -ForegroundColor Yellow
Write-Host "   - Open each URL in your browser" -ForegroundColor Gray
Write-Host "   - Click 'Advanced' and 'Accept Risk'" -ForegroundColor Gray
Write-Host "   - You need to do this for each domain`n" -ForegroundColor Gray

Write-Host "2. User Service Down:" -ForegroundColor Yellow
Write-Host "   - Check pod status above" -ForegroundColor Gray
Write-Host "   - Look for 'user-service' pod" -ForegroundColor Gray
Write-Host "   - Should show '1/1 Running'`n" -ForegroundColor Gray

Write-Host "3. Checkout Not Working:" -ForegroundColor Yellow
Write-Host "   - Make sure you're logged in first" -ForegroundColor Gray
Write-Host "   - Add items to cart" -ForegroundColor Gray
Write-Host "   - Click cart icon, then 'Checkout'" -ForegroundColor Gray
Write-Host "   - Fill shipping form" -ForegroundColor Gray
Write-Host "   - Choose payment method (Card/COD)`n" -ForegroundColor Gray

Write-Host "4. Browser Console Check:" -ForegroundColor Yellow
Write-Host "   - Press F12 in browser" -ForegroundColor Gray
Write-Host "   - Check Console tab for errors" -ForegroundColor Gray
Write-Host "   - Check Network tab for failed requests`n" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Quick Test Commands" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Test from within OpenShift cluster:" -ForegroundColor Yellow
Write-Host "oc run test-curl --image=curlimages/curl:latest --rm -i --restart=Never -n dry-fruits-platform -- curl -sk https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health" -ForegroundColor Gray

Write-Host "`nCheck logs:" -ForegroundColor Yellow
Write-Host "oc logs deployment/user-service -n dry-fruits-platform --tail=50" -ForegroundColor Gray
Write-Host "oc logs deployment/customer-portal -n dry-fruits-platform --tail=50" -ForegroundColor Gray
Write-Host "oc logs deployment/payment-service -n dry-fruits-platform --tail=50" -ForegroundColor Gray

Write-Host "`n"
