#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   DRY FRUITS MICROSERVICES - STATUS CHECK" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Container Status:" -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml ps

Write-Host ""
Write-Host "Health Checks:" -ForegroundColor Yellow

$services = @(
    @{name="API Gateway"; url="http://localhost:8080/actuator/health"},
    @{name="Eureka Server"; url="http://localhost:8761/actuator/health"},
    @{name="Customer Portal"; url="http://localhost:3000"},
    @{name="Admin Dashboard"; url="http://localhost:3001"},
    @{name="RabbitMQ Management"; url="http://localhost:15672"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.url -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $($service.name) - OK" -ForegroundColor Green
        } else {
            Write-Host "⚠ $($service.name) - Response: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ $($service.name) - Not responding" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Database Connection Test:" -ForegroundColor Yellow
try {
    $result = docker exec postgres-main pg_isready -U dry_fruits_user 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL - Connected" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL - Connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ PostgreSQL - Container not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Redis Connection Test:" -ForegroundColor Yellow
try {
    $result = docker exec redis-cache redis-cli ping 2>$null
    if ($result -eq "PONG") {
        Write-Host "✓ Redis - Connected" -ForegroundColor Green
    } else {
        Write-Host "✗ Redis - Connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Redis - Container not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "- Restart all:        docker-compose -f docker-compose-simple.yml restart" -ForegroundColor Gray
Write-Host "- View all logs:      docker-compose -f docker-compose-simple.yml logs -f" -ForegroundColor Gray
Write-Host "- Stop all:           docker-compose -f docker-compose-simple.yml down" -ForegroundColor Gray
Write-Host "- Rebuild & restart:  docker-compose -f docker-compose-simple.yml up -d --build" -ForegroundColor Gray
Write-Host ""