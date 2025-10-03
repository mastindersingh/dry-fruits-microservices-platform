# Configuration Management Strategy

## Problem Solved
Previously, every configuration change required rebuilding Docker images, which was:
- Time-consuming (3-5 minutes per build)
- Resource-intensive
- Error-prone
- Not production-ready

## Solution: Kubernetes ConfigMaps

### What We Did
1. **Extracted configurations** from Docker images into Kubernetes ConfigMaps
2. **Separated concerns** - application code vs configuration
3. **Made configurations dynamic** - no rebuilds needed

### Benefits
- ✅ **No Docker rebuilds** for configuration changes
- ✅ **Instant updates** - just update ConfigMap and restart pods
- ✅ **Environment-specific configs** - different ConfigMaps per environment
- ✅ **Version control** for configurations
- ✅ **Production-ready** approach

## How It Works

### 1. ConfigMaps Store Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: inventory-service-config
data:
  application.yml: |
    # Your entire Spring Boot configuration here
```

### 2. Pods Mount ConfigMaps as Volumes
```yaml
spec:
  containers:
  - name: inventory-service
    image: inventory-service:latest
    volumeMounts:
    - name: config-volume
      mountPath: /app/config
      readOnly: true
    env:
    - name: SPRING_CONFIG_LOCATION
      value: "classpath:/application.yml,file:/app/config/application.yml"
  volumes:
  - name: config-volume
    configMap:
      name: inventory-service-config
```

### 3. Spring Boot Loads External Configuration
Spring Boot automatically loads configuration from the mounted path.

## Making Configuration Changes

### Old Way (❌ Slow)
1. Edit `application.yml` in source code
2. Rebuild Docker image (3-5 minutes)
3. Update Kubernetes deployment
4. Wait for pod restart

### New Way (✅ Fast)
1. Edit `k8s/config-maps.yml`
2. Apply ConfigMap: `kubectl apply -f k8s/config-maps.yml`
3. Restart pods: `kubectl rollout restart deployment inventory-service -n dryfruit`
4. Done! (30 seconds total)

## Quick Commands

### Update Configuration
```bash
# 1. Edit k8s/config-maps.yml
# 2. Apply changes
kubectl apply -f k8s/config-maps.yml

# 3. Restart specific service
kubectl rollout restart deployment inventory-service -n dryfruit
kubectl rollout restart deployment shipping-service -n dryfruit

# Or restart all services
kubectl rollout restart deployment -n dryfruit
```

### Check Status
```bash
kubectl get pods -n dryfruit
kubectl get configmaps -n dryfruit
```

## File Structure
```
k8s/
├── config-maps.yml      # All service configurations
├── services.yml         # Deployments using ConfigMaps
├── infrastructure.yml   # Database, Redis, etc.
├── observability.yml   # Monitoring stack
└── frontend.yml        # Frontend applications
```

## Environment Management
For different environments, create separate ConfigMaps:
- `inventory-service-config-dev`
- `inventory-service-config-staging`
- `inventory-service-config-prod`

## Best Practices
1. **Never hardcode** sensitive data (use Secrets instead)
2. **Version control** your ConfigMaps
3. **Test configurations** in lower environments first
4. **Use meaningful names** for ConfigMaps
5. **Document** configuration changes

## Current Status
✅ All services now use ConfigMaps
✅ No more Docker rebuilds needed
✅ Fast configuration updates
✅ Production-ready setup