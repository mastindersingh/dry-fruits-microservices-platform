Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   DRY FRUITS MICROSERVICES - SIMPLE SETUP" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "OK - Docker is running" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[1/5] Cleaning up any existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml down -v 2>$null

Write-Host "[2/5] Building microservices..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml build

Write-Host "[3/5] Starting infrastructure services..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml up -d postgres redis rabbitmq

Write-Host "[4/5] Waiting for infrastructure to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "[5/5] Starting all microservices..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml up -d

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "    SETUP COMPLETE!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Services Status:" -ForegroundColor Cyan
docker-compose -f docker-compose-simple.yml ps

Write-Host ""
Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "- API Gateway:       http://localhost:8080" -ForegroundColor White
Write-Host "- Customer Portal:   http://localhost:3000" -ForegroundColor White
Write-Host "- Admin Dashboard:   http://localhost:3001" -ForegroundColor White
Write-Host "- Eureka Server:     http://localhost:8761" -ForegroundColor White
Write-Host "- RabbitMQ Admin:    http://localhost:15672 (admin/admin123)" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "- View logs: docker-compose -f docker-compose-simple.yml logs -f [service-name]" -ForegroundColor Gray
Write-Host "- Stop all:  docker-compose -f docker-compose-simple.yml down" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to continue"