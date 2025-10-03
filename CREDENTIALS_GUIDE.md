# 🔐 Dry Fruits Microservices Platform - Credentials Guide

## 🎯 Service Login Credentials

### 🖥️ **Frontend Applications**
| Service | URL | Username | Password | Notes |
|---------|-----|----------|----------|-------|
| **Customer Portal** | http://localhost:30900 | ❌ No Auth | ❌ No Auth | Public interface |
| **Admin Dashboard** | http://localhost:8080 | ❌ No Auth | ❌ No Auth | Admin interface (no auth) |

### 📊 **Observability Stack**
| Service | URL | Username | Password | Notes |
|---------|-----|----------|----------|-------|
| **Grafana** | http://localhost:3000 | **admin** | **grafana123** | Default admin account |
| **Prometheus** | http://localhost:9091 | ❌ No Auth | ❌ No Auth | Metrics collection |
| **Jaeger** | http://localhost:16686 | ❌ No Auth | ❌ No Auth | Distributed tracing |

### 🔧 **Backend Services** 
| Service | URL | Username | Password | Notes |
|---------|-----|----------|----------|-------|
| **Eureka Server** | http://localhost:8762 | ❌ No Auth | ❌ No Auth | Service Discovery |
| **Inventory Service** | http://localhost:8084 | ❌ No Auth | ❌ No Auth | REST API |
| **Shipping Service** | http://localhost:8085 | ❌ No Auth | ❌ No Auth | REST API |

### 🗄️ **Data Services**
| Service | Internal Access | Username | Password | Database/Purpose |
|---------|----------------|----------|----------|------------------|
| **PostgreSQL** | postgres:5432 | **dryfruits_user** | **dryfruits_pass123** | Main database |
| **Redis** | redis:6379 | ❌ No Auth | ❌ No Auth | Cache layer |
| **RabbitMQ** | rabbitmq:5672 | **admin** | **admin123** | Message queue |
| **RabbitMQ Management** | rabbitmq:15672 | **admin** | **admin123** | Web management interface |

## 🔍 **Internal Service Configurations**

### 📊 **Database Connections**
Both Inventory and Shipping services use these DB credentials:
- **Database Host**: `postgres:5432`
- **Database Name**: `dryfruits`
- **Username**: `dryfruits_user`
- **Password**: `dryfruits_pass123`

### 🐰 **Message Queue Connections**
Both Inventory and Shipping services use these RabbitMQ credentials:
- **RabbitMQ Host**: `rabbitmq:5672`
- **Username**: `admin`
- **Password**: `admin123`

## 🎯 **Quick Access Summary**

### ✅ **Services Requiring Login**
1. **Grafana Dashboard**: 
   - URL: http://localhost:3000
   - Login: `admin` / `grafana123`

### ❌ **Services with No Authentication**
- Customer Portal (http://localhost:30900)
- Admin Dashboard (http://localhost:8080)
- Prometheus (http://localhost:9091)
- Jaeger (http://localhost:16686)
- Eureka Server (http://localhost:8762)
- All REST API endpoints

## 🛠️ **Database Access (if needed)**

If you need direct database access for troubleshooting:

```bash
# Connect to PostgreSQL from within Kubernetes
kubectl exec -it postgres-[pod-id] -n dryfruit -- psql -U dryfruits_user -d dryfruits

# Or via port forwarding
kubectl port-forward svc/postgres 5432:5432 -n dryfruit
# Then connect: psql -h localhost -p 5432 -U dryfruits_user -d dryfruits
```

## 🔒 **Security Notes**

⚠️ **These are development credentials - DO NOT use in production!**

- Most services have no authentication for easier development
- Database and message queue credentials are hardcoded
- Grafana uses default admin credentials
- All credentials are visible in configuration files

For production deployment, implement proper:
- OAuth2/JWT authentication
- Secret management (Kubernetes Secrets)
- Database connection pooling with encrypted credentials
- Role-based access control (RBAC)