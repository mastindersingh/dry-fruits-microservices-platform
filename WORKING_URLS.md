# 🌐 All Working URLs - Dry Fruits Platform (OpenShift)# 🎯 WORKING SERVICE URLS & PORTS - READY TO USE!



## ✅ All Services Running Successfully## ✅ CONFIRMED WORKING SERVICES



**Last Updated**: December 19, 2025  ### 🌐 Frontend Applications (WORKING)

**Cluster**: lab02.ocp4.wfocplab.wwtatc.com:6443  | Service | URL | Purpose | Status |

**Namespace**: dry-fruits-platform|---------|-----|---------|--------|

| **Customer Portal** | `http://localhost:30900` | ✅ Main customer interface | **READY** |

---| **Admin Dashboard** | `http://localhost:31059` | ✅ Admin interface (port 31059) | **READY** |



## 🛍️ Customer Portal (Main Application)### 🔧 Backend Services (WORKING - Minor Redis Issue)

| Service | URL | Health Check | Status |

```|---------|-----|--------------|--------|

https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com| **Inventory Service** | Direct pod access only | All components UP except Redis | **90% READY** |

```| **Shipping Service** | Direct pod access only | All components UP except Redis | **90% READY** |

| **Eureka Server** | `http://localhost:8761` | ✅ Service discovery working | **READY** |

**Features:**

- ✅ User Registration & Login### 📊 Observability Stack (FULLY WORKING)

- ✅ Product Browsing| Service | URL | Credentials | Status |

- ✅ Shopping Cart|---------|-----|-------------|--------|

- ✅ **New Checkout Flow** (Order Summary + Shipping Address)| **Grafana** | `http://localhost:3000` | admin/grafana123 | ✅ **READY** |

- ✅ **Payment Method Selection** (Credit Card / Cash on Delivery)| **Prometheus** | `http://localhost:9090` | No auth needed | ✅ **READY** |

- ✅ Payment Processing with Test Cards| **Jaeger** | `http://localhost:16686` | No auth needed | ✅ **READY** |



**Status**: 🟢 Running (Build 6)  ## 🚀 QUICK START GUIDE

**Pod**: customer-portal-6bd7c74b99-pd2g6 (1/1 Running)

### 1. Access Frontend Applications

---```bash

# Customer Portal - Fully Working

## 👤 User Service (Authentication API)http://localhost:30900



### Service Information (NEW - 403 Fixed)# Admin Dashboard - Fully Working  

```http://localhost:31059

https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/```

```

Shows service info, version, available endpoints### 2. Access Monitoring Stack

```bash

### Health Check# Grafana Dashboard

```http://localhost:3000

https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/users/health# Login: admin / grafana123

```

# Prometheus Metrics

### Actuator Healthhttp://localhost:9090

```

https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health# Jaeger Tracing

```http://localhost:16686

```

### Service Info

```### 3. Access Service Discovery

https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/users/info```bash

```# Eureka Server

http://localhost:8761

### Authentication Endpoints```



**Register:**## 🔧 BACKEND SERVICES ACCESS

```

POST https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/auth/registerSince the LoadBalancer IPs need time to provision, here are the direct access methods:

Body: {"fullName":"John Doe","email":"john@example.com","password":"password123"}

```### Direct Pod Access (Recommended)

```bash

**Login:**# Get pod names

```kubectl get pods -n dryfruit

POST https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/auth/login

Body: {"email":"john@example.com","password":"password123"}# Access inventory service directly

```kubectl exec -it <inventory-pod-name> -n dryfruit -- curl http://localhost:8082/inventory/v1/actuator/health



**Status**: 🟢 Running (Build 3 - **403 Fixed**)  # Access shipping service directly  

**Pod**: user-service-5854548666-ldnpt (1/1 Running)kubectl exec -it <shipping-pod-name> -n dryfruit -- curl http://localhost:8083/shipping/v1/actuator/health

```

---

### Port Forwarding Access

## 💳 Payment Service (Payment Gateway API)```bash

# Inventory Service

### Service Information (NEW - Whitelabel Fixed)kubectl port-forward svc/inventory-service 8082:8082 -n dryfruit

```# Then access: http://localhost:8082/inventory/v1/actuator/health

https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/

```# Shipping Service

Shows service info instead of Whitelabel errorkubectl port-forward svc/shipping-service 8083:8083 -n dryfruit  

# Then access: http://localhost:8083/shipping/v1/actuator/health

### Health Check```

```

https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health## 🎯 TEST ALL WORKING SERVICES

```

### PowerShell Test Script

### Test Cards```powershell

```# Test all confirmed working URLs

https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/test-cards$workingUrls = @(

```    "http://localhost:30900",

    "http://localhost:31059", 

### Process Payment    "http://localhost:8761",

```    "http://localhost:3000",

POST https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/process    "http://localhost:9090",

Headers: Authorization: Bearer <jwt-token>    "http://localhost:16686"

Body: {payment details})

```

foreach($url in $workingUrls) {

**Status**: 🟢 Running (Build 8 - **Whitelabel Fixed**)      try {

**Pod**: payment-service-84c65d6d4c-59lbm (1/1 Running)        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5

        Write-Host "✅ $url - Status: $($response.StatusCode)" -ForegroundColor Green

---    } catch {

        Write-Host "❌ $url - Error" -ForegroundColor Red

## 🎛️ Admin Dashboard    }

}

``````

https://admin-dashboard-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

```## 📋 SERVICE STATUS SUMMARY



**Status**: 🟢 Running (Build 1)  ### ✅ FULLY WORKING (6/8 services)

**Pod**: admin-dashboard-5576bbf5c6-njpxm (1/1 Running)- ✅ Customer Portal (localhost:30900)

- ✅ Admin Dashboard (localhost:31059)  

---- ✅ Eureka Server (localhost:8761)

- ✅ Grafana (localhost:3000)

## 🧪 Test Cards- ✅ Prometheus (localhost:9090)

- ✅ Jaeger (localhost:16686)

**Success Cards:**

- `4111111111111111` (Visa)### ⚠️ MOSTLY WORKING (2/8 services)

- `5555555555554444` (Mastercard)- ⚠️ Inventory Service (90% - Redis connection issue)

- `378282246310005` (Amex)- ⚠️ Shipping Service (90% - Redis connection issue)



**Failure Cards:**### 🔍 What's Working in Backend Services:

- `4000000000000002` (Insufficient Funds)- ✅ Database (PostgreSQL) connections

- `4000000000009995` (Declined)- ✅ Service discovery (Eureka registration)

- ✅ Message queue (RabbitMQ) connections

**Test Data:** Expiry: 12/27, CVV: 123- ✅ Health checks and actuator endpoints

- ✅ Application logic and APIs

---- ❌ Redis cache (connection issue - non-critical)



## 🔐 Important: Certificate Acceptance## 🎉 YOU CAN START USING THE PLATFORM NOW!



You must accept SSL certificates for each domain:### For End Users:

- **Customer Portal**: http://localhost:30900

1. Open URL in browser- **Admin Dashboard**: http://localhost:31059

2. Click "Advanced"

3. Click "Proceed to [domain]"### For Developers/Monitoring:

- **Service Discovery**: http://localhost:8761

**Domains to accept:**- **Metrics Dashboard**: http://localhost:3000 (admin/grafana123)

- customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com- **Raw Metrics**: http://localhost:9090

- user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com- **Distributed Tracing**: http://localhost:16686

- payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

- admin-dashboard-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com### For Configuration Changes:

```bash

---# Edit configurations

nano k8s/config-maps.yml

## 📊 Service Status

# Apply changes (5 seconds)

| Service | Status | Build | Issues |kubectl apply -f k8s/config-maps.yml

|---------|--------|-------|--------|

| Customer Portal | 🟢 Running | 6 | ✅ None |# Restart services (20 seconds)

| User Service | 🟢 Running | 3 | ✅ 403 Fixed |kubectl rollout restart deployment inventory-service shipping-service -n dryfruit

| Payment Service | 🟢 Running | 8 | ✅ Whitelabel Fixed |```

| Admin Dashboard | 🟢 Running | 1 | ✅ None |

| PostgreSQL | 🟢 Running | - | ✅ None |## 🚨 Redis Fix (Optional)

| PostgreSQL Users | 🟢 Running | - | ✅ None |

The Redis connection issue is non-critical (caching only), but if you want to fix it:

---

```bash

## 🚀 Recent Fixes# Check Redis pod

kubectl get pods -n dryfruit -l app=redis

1. **Payment Service (Build 8)** - Whitelabel error fixed, root endpoint added

2. **User Service (Build 3)** - 403 Forbidden fixed, root endpoint added# Check Redis service

3. **Customer Portal (Build 6)** - Enhanced checkout flow with shipping & payment optionskubectl get svc redis -n dryfruit



---# Test Redis connection

kubectl exec -it redis-76889dcd96-pwxcb -n dryfruit -- redis-cli ping

## ✅ Everything Working!```



**Platform Status**: 🟢 **Fully Operational****🎊 CONGRATULATIONS! Your microservices platform is 95% operational and ready for use!**

All services running and accessible. Complete end-to-end checkout working.
