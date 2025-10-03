# Build and Deploy Script for Dry Fruits Microservices Platform

## Prerequisites
- Docker Desktop with Kubernetes enabled
- kubectl configured
- Maven 3.6+
- Java 17

## Quick Start Commands

### 1. Build All Services
```powershell
# Navigate to project root
cd c:\Users\masti\sciencekit\dry-fruits-microservices-complete

# Build all services with Docker
docker-compose build

# Or build individual services
cd services\api-gateway
docker build -t dryfruits-platform/api-gateway:1.0-SNAPSHOT .

cd ..\user-service  
docker build -t dryfruits-platform/user-service:1.0-SNAPSHOT .

cd ..\product-service
docker build -t dryfruits-platform/product-service:1.0-SNAPSHOT .

cd ..\order-service
docker build -t dryfruits-platform/order-service:1.0-SNAPSHOT .

cd ..\payment-service
docker build -t dryfruits-platform/payment-service:1.0-SNAPSHOT .
```

### 2. Run with Docker Compose (Recommended for Development)
```powershell
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f api-gateway
docker-compose logs -f user-service

# Stop all services
docker-compose down
```

### 3. Deploy to Kubernetes (Production)
```powershell
# Apply Kubernetes manifests
kubectl apply -f k8s\platform-deployment.yaml

# Check deployment status
kubectl get pods -n dryfruits-platform
kubectl get services -n dryfruits-platform

# Port forward to access API Gateway
kubectl port-forward service/api-gateway 8080:8080 -n dryfruits-platform

# Scale services
kubectl scale deployment api-gateway --replicas=3 -n dryfruits-platform
kubectl scale deployment user-service --replicas=3 -n dryfruits-platform
```

### 4. Testing the Platform
```powershell
# Health checks
curl http://localhost:8080/actuator/health
curl http://localhost:8761  # Eureka Dashboard

# API endpoints (once services are running)
curl http://localhost:8080/api/v1/products
curl http://localhost:8080/api/v1/users
```

## Service URLs

### Docker Compose
- API Gateway: http://localhost:8080
- Eureka Server: http://localhost:8761
- User Service: http://localhost:8081 (internal)
- Product Service: http://localhost:8082 (internal)
- Order Service: http://localhost:8083 (internal)
- Payment Service: http://localhost:8084 (internal)

### Kubernetes
- API Gateway: http://localhost:8080 (via port-forward)
- Ingress: https://dryfruits-platform.local (with ingress controller)

## Monitoring & Management
- Health Checks: /actuator/health
- Metrics: /actuator/metrics
- Prometheus: /actuator/prometheus
- Service Discovery: http://localhost:8761

## Development Workflow
1. Make code changes in any service
2. Rebuild the specific service: `docker-compose build <service-name>`
3. Restart the service: `docker-compose up -d <service-name>`
4. Test the changes

## Production Notes
- Use external databases instead of containerized PostgreSQL
- Configure proper secrets management
- Set up monitoring with Prometheus & Grafana
- Configure proper logging aggregation
- Use managed Kafka service
- Set resource limits based on load testing

## Troubleshooting
- Check service logs: `docker-compose logs <service-name>`
- Check Eureka dashboard for service registration
- Verify database connections
- Check Kafka topic creation