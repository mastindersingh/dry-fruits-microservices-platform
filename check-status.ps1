# Payment System - Quick Status Check
# Run after logging into OpenShift: oc login <your-cluster>

Write-Host "================================" -ForegroundColor Cyan
Write-Host "🚀 DRY FRUITS PLATFORM STATUS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if logged in
try {
    $currentUser = oc whoami 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Not logged into OpenShift!" -ForegroundColor Red
        Write-Host "Please run: oc login <your-cluster-url>" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Logged in as: $currentUser" -ForegroundColor Green
} catch {
    Write-Host "❌ OpenShift CLI not available" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 BUILD STATUS:" -ForegroundColor Cyan
Write-Host "----------------" -ForegroundColor Cyan

# Check builds
$builds = @(
    "user-service-build",
    "customer-portal-build", 
    "payment-service-build",
    "admin-dashboard-build"
)

foreach ($build in $builds) {
    $status = oc get builds -n dry-fruits-platform -l buildconfig=$build --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].status.phase}' 2>$null
    if ($status -eq "Complete") {
        Write-Host "  ✅ $build : Complete" -ForegroundColor Green
    } elseif ($status -eq "Running") {
        Write-Host "  ⏳ $build : Running..." -ForegroundColor Yellow
    } elseif ($status -eq "Failed") {
        Write-Host "  ❌ $build : Failed" -ForegroundColor Red
    } else {
        Write-Host "  ⚪ $build : Not started" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🐳 POD STATUS:" -ForegroundColor Cyan
Write-Host "--------------" -ForegroundColor Cyan

# Check key pods
$pods = @(
    "user-service",
    "customer-portal",
    "payment-service",
    "admin-dashboard",
    "postgres-users"
)

foreach ($pod in $pods) {
    $running = oc get pods -n dry-fruits-platform -l app=$pod -o jsonpath='{.items[0].status.phase}' 2>$null
    if ($running -eq "Running") {
        Write-Host "  ✅ $pod : Running" -ForegroundColor Green
    } elseif ($running -eq "Pending" -or $running -eq "ContainerCreating") {
        Write-Host "  ⏳ $pod : Starting..." -ForegroundColor Yellow
    } else {
        Write-Host "  ❌ $pod : Not running" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🌐 ROUTES (URLs):" -ForegroundColor Cyan
Write-Host "-----------------" -ForegroundColor Cyan

# Get routes
$routes = @(
    "customer-portal-route",
    "admin-dashboard-route",
    "user-service-route",
    "payment-service-route"
)

foreach ($route in $routes) {
    $url = oc get route $route -n dry-fruits-platform -o jsonpath='https://{.spec.host}' 2>$null
    if ($url) {
        Write-Host "  🔗 $route" -ForegroundColor White
        Write-Host "     $url" -ForegroundColor Blue
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "🧪 TESTING INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Customer Portal URL (above)" -ForegroundColor White
Write-Host "2. First, accept certificate for user-service-route and payment-service-route" -ForegroundColor White
Write-Host "3. Login or Register" -ForegroundColor White
Write-Host "4. Add items to cart" -ForegroundColor White
Write-Host "5. Click 'Proceed to Checkout'" -ForegroundColor White
Write-Host "6. Use test card:" -ForegroundColor White
Write-Host "   Card: 4111111111111111" -ForegroundColor Green
Write-Host "   Name: Test User" -ForegroundColor Green
Write-Host "   Expiry: 12/27" -ForegroundColor Green
Write-Host "   CVV: 123" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Documentation: PAYMENT_SERVICE_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
