# 🥜 Dry Fruits Microservices Platform - Complete System Documentation

## 📋 System Overview

This is a complete microservices-based e-commerce platform for dry fruits with modern architecture including frontend applications, backend services, and infrastructure components.

---

## 🔐 System Credentials & Access Information

### **Database Credentials**
- **PostgreSQL Database**
  - Host: `localhost:5432` (External) / `postgres-shared:5432` (Internal)
  - Database Name: `dryfruits_db`
  - Username: `dryfruits_user`
  - Password: `dryfruits_pass123`

### **Message Broker Credentials**
- **RabbitMQ**
  - Management UI: http://localhost:15672
  - Username: `admin`
  - Password: `admin123`
  - AMQP Port: `5672`
  - Management Port: `15672`

### **Cache Service**
- **Redis**
  - Host: `localhost:6379` (External) / `redis:6379` (Internal)
  - No authentication required

### **Service Discovery**
- **Eureka Server**
  - Dashboard: http://localhost:8761
  - No authentication required

---

## 🌐 Application URLs & Access Points

### **Frontend Applications**
1. **Customer Portal** (Public Interface)
   - URL: http://localhost:3000
   - Purpose: Customer-facing e-commerce portal
   - Features: Product browsing, cart management, order tracking

2. **Admin Dashboard** (Internal Interface)
   - URL: http://localhost:3001
   - Purpose: Internal team management system
   - Features: Inventory management, order processing, analytics, system monitoring

### **Backend API Services**
1. **Eureka Server** (Service Discovery)
   - URL: http://localhost:8761
   - Health Check: http://localhost:8761/actuator/health

2. **Inventory Service** (Product Management)
   - URL: http://localhost:8084
   - Base Path: `/inventory/v1`
   - Health Check: http://localhost:8084/inventory/v1/actuator/health
   - API Documentation: http://localhost:8084/inventory/v1/swagger-ui.html

3. **Shipping Service** (Order Fulfillment)
   - URL: http://localhost:8085
   - Base Path: `/shipping/v1`
   - Health Check: http://localhost:8085/shipping/v1/actuator/health
   - API Documentation: http://localhost:8085/shipping/v1/swagger-ui.html

---

## 🛠️ System Installation & Setup Guide

### **Prerequisites**
- Docker Desktop (Windows/Mac/Linux)
- Git (for cloning repository)
- 8GB+ RAM recommended
- 10GB+ free disk space

### **Quick Start Installation**

#### Step 1: Clone Repository
```bash
git clone <repository-url>
cd dry-fruits-microservices-complete
```

#### Step 2: Start Infrastructure Services
```bash
docker-compose -f docker-compose-light.yml up -d postgres-shared redis rabbitmq
```

#### Step 3: Build All Services
```bash
docker-compose -f docker-compose-light.yml build
```

#### Step 4: Start All Services
```bash
docker-compose -f docker-compose-light.yml up -d
```

#### Step 5: Start Frontend Applications
```bash
docker-compose -f frontend-only.yml up -d
```

### **Verification Steps**
1. Check all containers are running:
   ```bash
   docker ps
   ```

2. Verify frontend applications:
   - Customer Portal: http://localhost:3000
   - Admin Dashboard: http://localhost:3001

3. Verify backend services:
   - Eureka Dashboard: http://localhost:8761
   - Service Health Checks: Wait 2-3 minutes for services to fully start

---

## 🏗️ Architecture Components

### **Frontend Layer**
- **Technology**: Node.js, HTML5, CSS3, Bootstrap 5, JavaScript
- **Services**: 2 applications (Customer Portal, Admin Dashboard)
- **Deployment**: Docker containers with Node.js Alpine base

### **Backend Layer**
- **Technology**: Spring Boot 3.2.0, Java 17, Maven
- **Architecture**: Microservices with Service Discovery
- **Services**: 3 microservices (Eureka, Inventory, Shipping)
- **Deployment**: Docker containers with Eclipse Temurin JRE

### **Infrastructure Layer**
- **Database**: PostgreSQL 15 Alpine
- **Cache**: Redis 7 Alpine
- **Message Broker**: RabbitMQ 3 with Management UI
- **Service Discovery**: Netflix Eureka
- **Containerization**: Docker & Docker Compose

---

## 📊 Service Status & Health Monitoring

### **Infrastructure Services** ✅
| Service | Status | Port | Health Check |
|---------|--------|------|--------------|
| PostgreSQL | Running | 5432 | `docker exec postgres-shared psql -U dryfruits_user -d dryfruits_db -c "SELECT 1;"` |
| Redis | Running | 6379 | `docker exec redis redis-cli ping` |
| RabbitMQ | Running | 5672/15672 | http://localhost:15672 |

### **Frontend Applications** ✅
| Application | Status | Port | URL |
|-------------|--------|------|-----|
| Customer Portal | Running | 3000 | http://localhost:3000 |
| Admin Dashboard | Running | 3001 | http://localhost:3001 |

### **Backend Services** ⚠️ (Starting)
| Service | Status | Port | Health Check |
|---------|--------|------|--------------|
| Eureka Server | Running | 8761 | http://localhost:8761 |
| Inventory Service | Starting | 8084 | http://localhost:8084/inventory/v1/actuator/health |
| Shipping Service | Starting | 8085 | http://localhost:8085/shipping/v1/actuator/health |

---

## 🔧 Troubleshooting Guide

### **Common Issues & Solutions**

#### Issue 1: Services not starting
**Solution**: Check Docker resources and restart services
```bash
docker-compose -f docker-compose-light.yml restart
```

#### Issue 2: Database connection errors
**Solution**: Verify PostgreSQL is running and accessible
```bash
docker logs postgres-shared
docker exec postgres-shared psql -U dryfruits_user -d dryfruits_db -c "SELECT 1;"
```

#### Issue 3: Frontend not loading
**Solution**: Check if containers are running and ports are available
```bash
docker ps --filter "name=customer-portal|admin-dashboard"
```

#### Issue 4: Service discovery issues
**Solution**: Wait 2-3 minutes for services to register with Eureka
- Check Eureka dashboard: http://localhost:8761

### **Useful Docker Commands**

#### View all containers:
```bash
docker ps -a
```

#### Check service logs:
```bash
docker logs <service-name>
```

#### Restart specific service:
```bash
docker-compose -f docker-compose-light.yml restart <service-name>
```

#### Stop all services:
```bash
docker-compose -f docker-compose-light.yml down
docker-compose -f frontend-only.yml down
```

#### Clean up everything:
```bash
docker-compose -f docker-compose-light.yml down -v
docker-compose -f frontend-only.yml down -v
docker system prune -f
```

---

## 📝 API Documentation

### **Inventory Service API**
- **Base URL**: http://localhost:8084/inventory/v1
- **Endpoints**:
  - `GET /products` - List all products
  - `GET /products/{id}` - Get product by ID
  - `POST /products` - Create new product
  - `PUT /products/{id}` - Update product
  - `DELETE /products/{id}` - Delete product

### **Shipping Service API**
- **Base URL**: http://localhost:8085/shipping/v1
- **Endpoints**:
  - `GET /shipments` - List all shipments
  - `GET /shipments/{id}` - Get shipment by ID
  - `POST /shipments` - Create new shipment
  - `PUT /shipments/{id}` - Update shipment status

---

## 🔒 Security Configuration

### **Default Security Settings**
- Frontend applications: No authentication (demo environment)
- Backend services: Basic security with Spring Security
- Database: Username/password authentication
- RabbitMQ: Admin credentials required for management interface

### **Production Recommendations**
1. Enable HTTPS/TLS for all services
2. Implement JWT-based authentication
3. Use secrets management for credentials
4. Enable network policies and firewalls
5. Regular security updates and vulnerability scanning

---

## 🚀 Development & Deployment

### **Local Development Setup**
1. Install Docker Desktop
2. Clone repository
3. Run `docker-compose -f docker-compose-light.yml up -d`
4. Access applications via browser

### **Production Deployment**
1. Use orchestration platforms (Kubernetes, Docker Swarm)
2. Implement CI/CD pipelines
3. Use managed databases and message brokers
4. Set up monitoring and logging
5. Configure load balancers and auto-scaling

---

## 📞 Support & Maintenance

### **System Monitoring**
- **Health Checks**: All services include health check endpoints
- **Logs**: Centralized logging via Docker logs
- **Metrics**: Spring Boot Actuator endpoints available

### **Backup & Recovery**
- **Database**: Regular PostgreSQL backups recommended
- **Configuration**: Version control for all configuration files
- **Images**: Container images should be versioned and stored in registry

---

## 📈 Performance Specifications

### **Resource Requirements**
- **Minimum**: 4GB RAM, 2 CPU cores, 5GB disk space
- **Recommended**: 8GB RAM, 4 CPU cores, 10GB disk space
- **Production**: 16GB+ RAM, 8+ CPU cores, 50GB+ disk space

### **Scalability**
- Frontend: Stateless, can be horizontally scaled
- Backend: Microservices architecture supports independent scaling
- Database: Can be configured with read replicas
- Cache: Redis can be clustered for high availability

---

*Last Updated: October 1, 2025*
*Version: 1.0.0*