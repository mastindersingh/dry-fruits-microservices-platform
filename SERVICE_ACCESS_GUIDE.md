# 🚀 Dry Fruits Microservices - Complete Service Access Guide

## 📋 All Service URLs and Ports

### 🌐 Frontend Applications
| Service | URL | Purpose | Status |
|---------|-----|---------|--------|
| **Customer Portal** | http://localhost:30900 | Main customer interface | ✅ Ready |
| **Admin Dashboard** | http://localhost:31059 | Administrative interface with auth | ✅ Ready |

### 🔧 Backend Microservices
| Service | URL | API Context | Health Check | Status |
|---------|-----|-------------|--------------|--------|
| **Inventory Service** | http://localhost:8082 | `/inventory/v1` | http://localhost:8082/inventory/v1/actuator/health | ✅ Ready |
| **Shipping Service** | http://localhost:8083 | `/shipping/v1` | http://localhost:8083/shipping/v1/actuator/health | ✅ Ready |
| **Eureka Server** | http://localhost:8761 | Service Discovery | http://localhost:8761 | ✅ Ready |

### 📊 Observability Stack
| Service | URL | Purpose | Credentials | Status |
|---------|-----|---------|-------------|--------|
| **Grafana** | http://localhost:3000 | Metrics Dashboard | admin/grafana123 | ✅ Ready |
| **Prometheus** | http://localhost:9090 | Metrics Collection | - | ✅ Ready |
| **Jaeger** | http://localhost:16686 | Distributed Tracing | - | ✅ Ready |

### 💾 Infrastructure Services (Internal)
| Service | Internal URL | Purpose | Port |
|---------|-------------|---------|------|
| **PostgreSQL** | postgres:5432 | Database | 5432 |
| **Redis** | redis:6379 | Cache | 6379 |
| **RabbitMQ** | rabbitmq:5672 | Message Queue | 5672 |
| **RabbitMQ Management** | rabbitmq:15672 | Queue Management | 15672 |

## 🔑 Service Credentials

### Admin Dashboard
- **Username**: admin
- **Password**: admin123

### Manager Dashboard  
- **Username**: manager
- **Password**: manager123

### Grafana
- **Username**: admin
- **Password**: grafana123

### Database
- **Database**: dryfruits
- **Username**: dryfruits_user
- **Password**: dryfruits_pass123

### RabbitMQ
- **Username**: admin
- **Password**: admin123

## 🧪 Quick Health Checks

### Test All Services
```powershell
# Frontend Services
Invoke-WebRequest -Uri "http://localhost:30900" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:31059" -UseBasicParsing

# Backend Services  
Invoke-WebRequest -Uri "http://localhost:8082/inventory/v1/actuator/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8083/shipping/v1/actuator/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8761" -UseBasicParsing

# Observability
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:9090" -UseBasicParsing  
Invoke-WebRequest -Uri "http://localhost:16686" -UseBasicParsing
```

### Individual Service Tests
```bash
# Inventory Service
curl http://localhost:8082/inventory/v1/actuator/health

# Shipping Service  
curl http://localhost:8083/shipping/v1/actuator/health

# Service Discovery (Eureka)
curl http://localhost:8761/eureka/apps

# Prometheus Targets
curl http://localhost:9090/api/v1/targets
```

## 🔄 Service Management Commands

### Apply Configuration Changes
```bash
# Update configurations
kubectl apply -f k8s/config-maps.yml

# Restart services to pick up changes
kubectl rollout restart deployment inventory-service -n dryfruit
kubectl rollout restart deployment shipping-service -n dryfruit
```

### Check Service Status
```bash
# All pods
kubectl get pods -n dryfruit

# All services  
kubectl get svc -n dryfruit

# Specific service logs
kubectl logs -f deployment/inventory-service -n dryfruit
kubectl logs -f deployment/shipping-service -n dryfruit
```

### Port Forwarding (Alternative Access)
```bash
# If LoadBalancer IPs don't work, use port forwarding:
kubectl port-forward svc/inventory-lb 8082:8082 -n dryfruit
kubectl port-forward svc/shipping-lb 8083:8083 -n dryfruit
kubectl port-forward svc/prometheus-lb 9090:9090 -n dryfruit
kubectl port-forward svc/jaeger-lb 16686:16686 -n dryfruit
```

## 🎯 Testing Workflow

### 1. Check All Services Are Running
```bash
kubectl get pods -n dryfruit
# All should show "Running" status
```

### 2. Test Service Discovery
```bash
# Check Eureka dashboard
curl http://localhost:8761
# Should show registered services
```

### 3. Test API Endpoints
```bash
# Inventory API
curl http://localhost:8082/inventory/v1/actuator/health

# Shipping API  
curl http://localhost:8083/shipping/v1/actuator/health
```

### 4. Check Observability
```bash
# Prometheus metrics
curl http://localhost:9090/api/v1/targets

# Grafana dashboard
# Login at http://localhost:3000 with admin/grafana123

# Jaeger traces
# Open http://localhost:16686 in browser
```

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐
│  Customer       │    │  Admin          │
│  Portal         │    │  Dashboard      │  
│  :30900         │    │  :31059         │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌─────────────────┐
         │  Eureka Server  │
         │  :8761          │
         └─────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Inventory   │ │ Shipping    │ │ Observability│
│ Service     │ │ Service     │ │ Stack       │
│ :8082       │ │ :8083       │ │             │
└─────────────┘ └─────────────┘ └─────────────┘
    │                │                │
    └────────────────┼────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ PostgreSQL  │ │ Redis       │ │ RabbitMQ    │
│ :5432       │ │ :6379       │ │ :5672       │
└─────────────┘ └─────────────┘ └─────────────┘
```

## 🚨 Troubleshooting

### If Services Are Down
1. Check pod status: `kubectl get pods -n dryfruit`
2. Check logs: `kubectl logs <pod-name> -n dryfruit`
3. Restart service: `kubectl rollout restart deployment <service-name> -n dryfruit`

### If URLs Don't Work
1. Check service status: `kubectl get svc -n dryfruit`
2. Use port forwarding as alternative
3. Check if LoadBalancer has external IP assigned

### Configuration Changes
1. Edit `k8s/config-maps.yml`
2. Apply: `kubectl apply -f k8s/config-maps.yml`
3. Restart: `kubectl rollout restart deployment <service> -n dryfruit`

## ✅ Current Status
- ✅ All services deployed with ConfigMaps
- ✅ LoadBalancer services created
- ✅ Observability stack ready
- ✅ Authentication implemented
- ✅ No Docker rebuilds needed for config changes
- ✅ Production-ready setup

**🎉 Your microservices platform is ready to use!**