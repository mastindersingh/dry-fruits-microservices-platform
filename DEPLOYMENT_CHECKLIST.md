# 🚀 OpenShift Deployment - Quick Start Checklist

## Pre-Deployment Checklist

### ✅ **Code Ready:**
- [x] OpenShift application profiles created for all services
- [x] Kubernetes deployment manifests created
- [x] OpenShift BuildConfigs prepared
- [x] Environment variables externalized
- [x] Health check endpoints configured

### ✅ **OpenShift Requirements:**
- [ ] OpenShift CLI (`oc`) installed
- [ ] Logged into OpenShift cluster: `oc login <cluster-url>`
- [ ] Sufficient resources available (~4GB memory, ~2 CPU cores)
- [ ] GitHub repository accessible from OpenShift cluster

## 🎯 **Deployment Commands**

### 1. **Quick Deploy (All-in-One)**
```bash
# Windows
deploy-ocp.bat

# Linux/Mac  
chmod +x deploy-ocp.sh
./deploy-ocp.sh
```

### 2. **Step-by-Step Deploy**
```bash
# Login to OpenShift
oc login <your-cluster-url>

# Create namespace and config
oc apply -f k8s/00-namespace-config.yaml

# Setup image builds
oc apply -f k8s/04-builds.yaml

# Start building images
oc start-build eureka-server-build -n dry-fruits-platform
oc start-build user-service-build -n dry-fruits-platform
oc start-build product-service-build -n dry-fruits-platform
oc start-build order-service-build -n dry-fruits-platform
oc start-build api-gateway-build -n dry-fruits-platform
oc start-build customer-portal-build -n dry-fruits-platform

# Wait for builds to complete
oc get builds -n dry-fruits-platform -w

# Deploy infrastructure
oc apply -f k8s/01-infrastructure.yaml

# Deploy core services
oc apply -f k8s/02-core-services.yaml

# Deploy gateway and frontend
oc apply -f k8s/03-gateway-frontend.yaml
```

## 🔍 **Monitoring Deployment**

### Check Status
```bash
# Pod status
oc get pods -n dry-fruits-platform

# Service status
oc get svc -n dry-fruits-platform

# Routes (external access)
oc get routes -n dry-fruits-platform

# Overall status
oc get all -n dry-fruits-platform
```

### View Logs
```bash
# Real-time logs for a service
oc logs deployment/user-service -n dry-fruits-platform -f

# Recent logs for all services
oc logs -l app=user-service -n dry-fruits-platform --tail=50
```

## 🎯 **Expected Endpoints**

After successful deployment:
- **API Gateway**: `https://api-gateway-route-dry-fruits-platform.apps.<cluster>.com`
- **Customer Portal**: `https://customer-portal-route-dry-fruits-platform.apps.<cluster>.com`
- **Eureka Dashboard**: Internal service discovery (accessible via port-forward)

## 🔧 **Common Operations**

### Scale Services
```bash
# Scale up for load testing
oc scale deployment/user-service --replicas=3 -n dry-fruits-platform
oc scale deployment/product-service --replicas=3 -n dry-fruits-platform

# Scale down to save resources
oc scale deployment/user-service --replicas=1 -n dry-fruits-platform
```

### Update Configuration
```bash
# Edit environment variables
oc edit configmap platform-config -n dry-fruits-platform

# Edit secrets
oc edit secret platform-secrets -n dry-fruits-platform

# Restart services to pick up changes
oc rollout restart deployment/user-service -n dry-fruits-platform
```

### Database Access
```bash
# Connect to PostgreSQL
oc rsh deployment/postgres -n dry-fruits-platform
psql -U dry_fruits_user -d dry_fruits_db

# Check Redis cache
oc rsh deployment/redis -n dry-fruits-platform
redis-cli
```

## 🚨 **Troubleshooting**

### Pods Not Starting
```bash
# Check pod details
oc describe pod <pod-name> -n dry-fruits-platform

# Check events
oc get events -n dry-fruits-platform --sort-by='.lastTimestamp'

# Check resource limits
oc describe limitrange -n dry-fruits-platform
```

### Build Issues
```bash
# Check build logs
oc logs build/<build-name> -n dry-fruits-platform

# Restart failed build
oc start-build <build-config-name> -n dry-fruits-platform
```

### Service Connectivity
```bash
# Test internal connectivity
oc rsh deployment/api-gateway -n dry-fruits-platform
curl http://user-service:8080/actuator/health

# Port forward for external testing
oc port-forward svc/api-gateway-service 8080:8080 -n dry-fruits-platform
```

## 🔄 **Update Workflow**

### Code Changes
1. Push changes to GitHub
2. Rebuild affected services:
   ```bash
   oc start-build user-service-build -n dry-fruits-platform
   ```
3. Services will auto-update with new images

### Configuration Changes
1. Update ConfigMap or Secret
2. Restart affected deployments:
   ```bash
   oc rollout restart deployment/user-service -n dry-fruits-platform
   ```

## 🧹 **Cleanup**

### Remove Everything
```bash
oc delete namespace dry-fruits-platform
```

### Selective Cleanup
```bash
# Remove services only (keep infrastructure)
oc delete -f k8s/02-core-services.yaml
oc delete -f k8s/03-gateway-frontend.yaml

# Remove builds
oc delete -f k8s/04-builds.yaml
```

## 📊 **Resource Usage**

Expected resource consumption:
- **PostgreSQL**: 256Mi memory, 250m CPU
- **Redis**: 128Mi memory, 100m CPU  
- **Eureka Server**: 512Mi memory, 250m CPU
- **User Service**: 512Mi memory, 250m CPU (x2 replicas)
- **Product Service**: 512Mi memory, 250m CPU (x2 replicas)
- **Order Service**: 512Mi memory, 250m CPU (x2 replicas)
- **API Gateway**: 512Mi memory, 250m CPU (x2 replicas)
- **Customer Portal**: 128Mi memory, 100m CPU (x2 replicas)

**Total**: ~4GB memory, ~2.5 CPU cores

---

🎉 **Your simplified dry fruits microservices platform is ready for OpenShift deployment!**