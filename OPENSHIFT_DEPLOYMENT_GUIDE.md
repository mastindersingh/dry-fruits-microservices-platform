# 🚀 Dry Fruits Platform - OpenShift Deployment Guide

## Essential Microservices for OpenShift

This deployment focuses on **5 core microservices** for optimal resource usage and complexity management:

### Core Services:
1. **Eureka Server** - Service Discovery
2. **User Service** - Authentication & User Management  
3. **Product Service** - Product Catalog (with Redis caching)
4. **Order Service** - Core Business Logic
5. **API Gateway** - Single Entry Point

### Infrastructure:
- **PostgreSQL** - Shared Database
- **Redis** - Product Caching
- **Customer Portal** - Frontend Application

## Prerequisites

1. **OpenShift CLI (oc)** installed
2. **Access to OpenShift cluster** 
3. **Sufficient cluster resources:**
   - Memory: ~4GB total
   - CPU: ~2 cores total
   - Storage: ~5GB

## Deployment Steps

### 1. Login to OpenShift
```bash
oc login <your-openshift-cluster-url>
```

### 2. Build Container Images (OpenShift S2I)
```bash
# Create builds and image streams
oc apply -f k8s/04-builds.yaml

# Start all builds
oc start-build eureka-server-build -n dry-fruits-platform
oc start-build user-service-build -n dry-fruits-platform  
oc start-build product-service-build -n dry-fruits-platform
oc start-build order-service-build -n dry-fruits-platform
oc start-build api-gateway-build -n dry-fruits-platform
oc start-build customer-portal-build -n dry-fruits-platform

# Monitor builds
oc get builds -n dry-fruits-platform -w
```

### 3. Deploy Platform (Automated)
```bash
# Windows
deploy-ocp.bat

# Linux/Mac  
chmod +x deploy-ocp.sh
./deploy-ocp.sh
```

### 4. Manual Deployment (Alternative)
```bash
# Step by step
oc apply -f k8s/00-namespace-config.yaml
oc apply -f k8s/01-infrastructure.yaml
oc apply -f k8s/02-core-services.yaml
oc apply -f k8s/03-gateway-frontend.yaml
```

## Monitoring Deployment

### Check Pod Status
```bash
oc get pods -n dry-fruits-platform
```

### View Logs
```bash
# All services
oc logs -l app=user-service -n dry-fruits-platform

# Specific service
oc logs deployment/user-service -n dry-fruits-platform -f
```

### Check Routes (External Access)
```bash
oc get routes -n dry-fruits-platform
```

## Access Points

After deployment, you'll get OpenShift routes like:
- **API Gateway**: `https://api-gateway-route-dry-fruits-platform.apps.your-cluster.com`
- **Customer Portal**: `https://customer-portal-route-dry-fruits-platform.apps.your-cluster.com`

## Scaling Services

```bash
# Scale up for higher load
oc scale deployment/user-service --replicas=3 -n dry-fruits-platform
oc scale deployment/product-service --replicas=3 -n dry-fruits-platform

# Scale down to save resources
oc scale deployment/user-service --replicas=1 -n dry-fruits-platform
```

## Configuration Management

### Update Environment Variables
```bash
# Edit the ConfigMap
oc edit configmap platform-config -n dry-fruits-platform

# Edit Secrets
oc edit secret platform-secrets -n dry-fruits-platform

# Restart services to pick up changes
oc rollout restart deployment/user-service -n dry-fruits-platform
```

### Database Configuration
The platform uses a single PostgreSQL database with these schemas:
- `users` - User data
- `products` - Product catalog
- `orders` - Order information

## Troubleshooting

### Common Issues:

1. **Pods not starting:**
   ```bash
   oc describe pod <pod-name> -n dry-fruits-platform
   oc logs <pod-name> -n dry-fruits-platform
   ```

2. **Image pull issues:**
   ```bash
   oc get builds -n dry-fruits-platform
   oc logs build/<build-name> -n dry-fruits-platform
   ```

3. **Service connectivity:**
   ```bash
   oc get svc -n dry-fruits-platform
   oc port-forward svc/api-gateway-service 8080:8080 -n dry-fruits-platform
   ```

### Debug Commands:
```bash
# Get all resources
oc get all -n dry-fruits-platform

# Check resource usage
oc top pods -n dry-fruits-platform

# Connect to database
oc rsh deployment/postgres -n dry-fruits-platform
psql -U dry_fruits_user -d dry_fruits_db

# Check Redis
oc rsh deployment/redis -n dry-fruits-platform
redis-cli
```

## Resource Optimization

For **development/testing environments:**
```bash
# Reduce replicas
oc scale deployment --replicas=1 --all -n dry-fruits-platform

# Reduce resource limits
oc patch deployment/user-service -n dry-fruits-platform -p='{"spec":{"template":{"spec":{"containers":[{"name":"user-service","resources":{"limits":{"memory":"512Mi","cpu":"250m"}}}]}}}}'
```

## Cleanup

```bash
# Remove everything
oc delete namespace dry-fruits-platform

# Or remove specific components
oc delete -f k8s/03-gateway-frontend.yaml
oc delete -f k8s/02-core-services.yaml
oc delete -f k8s/01-infrastructure.yaml
```

## Next Steps

1. **Setup CI/CD Pipeline** with OpenShift Pipelines (Tekton)
2. **Add Health Monitoring** with OpenShift built-in monitoring
3. **Configure Autoscaling** with HorizontalPodAutoscaler
4. **Add SSL/TLS certificates** for production routes
5. **Implement backup strategy** for PostgreSQL data

## Production Considerations

- Use **persistent storage** for PostgreSQL
- Configure **resource quotas** and **limits**
- Set up **network policies** for security
- Enable **pod disruption budgets**
- Configure **liveness/readiness probes** properly
- Use **secrets** for all sensitive data

---

This simplified deployment gives you a working microservices platform in OpenShift with minimal complexity and resource usage!