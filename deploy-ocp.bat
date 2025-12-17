@echo off
echo ================================================
echo    DRY FRUITS PLATFORM - OPENSHIFT DEPLOYMENT
echo ================================================
echo.

REM Check if oc CLI is available
oc version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: OpenShift CLI (oc) is not installed or not in PATH
    echo Please install oc CLI and login to your OpenShift cluster
    pause
    exit /b 1
)

REM Check if logged in to OpenShift
oc whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Not logged in to OpenShift cluster
    echo Please run: oc login ^<your-cluster-url^>
    pause
    exit /b 1
)

echo ✓ OpenShift CLI available
oc whoami
echo.

echo [1/6] Creating namespace and configuration...
oc apply -f k8s/00-namespace-config.yaml

echo [2/6] Deploying infrastructure services (PostgreSQL, Redis)...
oc apply -f k8s/01-infrastructure.yaml

echo [3/6] Waiting for infrastructure to be ready...
echo   - Waiting for PostgreSQL...
oc wait --for=condition=available --timeout=300s deployment/postgres -n dry-fruits-platform
echo   - Waiting for Redis...
oc wait --for=condition=available --timeout=300s deployment/redis -n dry-fruits-platform

echo [4/6] Deploying core microservices...
oc apply -f k8s/02-core-services.yaml

echo [5/6] Waiting for services to be ready...
echo   - Waiting for Eureka Server...
oc wait --for=condition=available --timeout=300s deployment/eureka-server -n dry-fruits-platform
echo   - Waiting for User Service...
oc wait --for=condition=available --timeout=300s deployment/user-service -n dry-fruits-platform
echo   - Waiting for Product Service...
oc wait --for=condition=available --timeout=300s deployment/product-service -n dry-fruits-platform
echo   - Waiting for Order Service...
oc wait --for=condition=available --timeout=300s deployment/order-service -n dry-fruits-platform

echo [6/6] Deploying API Gateway and Frontend...
oc apply -f k8s/03-gateway-frontend.yaml

echo.
echo ================================================
echo     DEPLOYMENT COMPLETE!
echo ================================================
echo.

echo Getting deployment status...
oc get pods -n dry-fruits-platform

echo.
echo Routes (External Access):
oc get routes -n dry-fruits-platform

echo.
echo Next Steps:
echo 1. Build and push your container images to the OpenShift registry
echo 2. Update image references in the YAML files
echo 3. Access your application via the routes shown above
echo.
echo Useful Commands:
echo - View pods: oc get pods -n dry-fruits-platform
echo - View logs: oc logs deployment/user-service -n dry-fruits-platform
echo - Scale service: oc scale deployment/user-service --replicas=3 -n dry-fruits-platform
echo - Delete all: oc delete namespace dry-fruits-platform
echo.
pause