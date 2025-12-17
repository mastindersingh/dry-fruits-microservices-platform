@echo off
echo ================================================
echo    DRY FRUITS MICROSERVICES - SIMPLE SETUP
echo ================================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [1/5] Cleaning up any existing containers...
docker-compose -f docker-compose-simple.yml down -v 2>nul

echo [2/5] Building microservices...
docker-compose -f docker-compose-simple.yml build

echo [3/5] Starting infrastructure services (Database, Redis, RabbitMQ)...
docker-compose -f docker-compose-simple.yml up -d postgres redis rabbitmq

echo [4/5] Waiting for infrastructure to be ready...
timeout /t 30 /nobreak > nul

echo [5/5] Starting all microservices...
docker-compose -f docker-compose-simple.yml up -d

echo.
echo ================================================
echo    SETUP COMPLETE!
echo ================================================
echo.
echo Services Status:
docker-compose -f docker-compose-simple.yml ps

echo.
echo Access Points:
echo - API Gateway:       http://localhost:8080
echo - Customer Portal:   http://localhost:3000
echo - Admin Dashboard:   http://localhost:3001
echo - Eureka Server:     http://localhost:8761
echo - RabbitMQ Admin:    http://localhost:15672 (admin/admin123)
echo.
echo To view logs: docker-compose -f docker-compose-simple.yml logs -f [service-name]
echo To stop all:  docker-compose -f docker-compose-simple.yml down
echo.
pause