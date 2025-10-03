# 🥜 Dry Fruits Microservices Platform# Dry Fruits Microservices Platform - Complete Architecture



A complete e-commerce microservices platform for dry fruits business with modern architecture and comprehensive frontend applications.## 🏗️ **Complete Microservices Stack**



## 🚀 Quick Start### **Core Services:**

1. **API Gateway** - Routes requests, authentication

### Prerequisites2. **User Service** - Customer & seller management

- Docker Desktop installed and running3. **Product Service** - Product catalog management

- 8GB+ RAM recommended4. **Order Service** - Order processing & workflow

- 10GB+ free disk space5. **Payment Service** - Payment processing & fees

6. **Inventory Service** - Stock tracking & management

### One-Command Setup7. **Shipping Service** - Logistics & delivery

8. **Notification Service** - Email/SMS notifications

**Windows:**9. **Analytics Service** - Business intelligence

```bash10. **Quality Service** - Seller verification & product quality

setup.bat

```### **Infrastructure Services:**

11. **Config Server** - Centralized configuration

**Linux/Mac:**12. **Service Discovery** - Service registration

```bash13. **Message Broker** - Kafka for events

chmod +x setup.sh14. **Database Services** - PostgreSQL cluster

./setup.sh

```## 🐳 **Docker & Kubernetes Ready**



### Manual Setup- **Each service** has its own Docker image

```bash- **Production-ready** Kubernetes deployments

# 1. Start infrastructure- **Auto-scaling** based on load

docker-compose -f docker-compose-light.yml up -d postgres-shared redis rabbitmq- **Health checks & monitoring**

- **Service mesh** with Istio (optional)

# 2. Build services

docker-compose -f docker-compose-light.yml build## 🎯 **Business Benefits**



# 3. Start backend services### **Scalability**

docker-compose -f docker-compose-light.yml up -d eureka-server inventory-service shipping-service- Scale each service independently

- Handle millions of transactions

# 4. Start frontend- Auto-scale during peak seasons

docker-compose -f frontend-only.yml up -d

```### **Reliability**

- If one service fails, others continue

## 🌐 Access Points- Zero-downtime deployments

- Fault tolerance & circuit breakers

- **Customer Portal**: http://localhost:3000

- **Admin Dashboard**: http://localhost:3001### **Development Speed**

- **Service Discovery**: http://localhost:8761- Teams work on different services

- **RabbitMQ Management**: http://localhost:15672- Independent deployments

- Technology flexibility per service

## 🔐 Default Credentials

### **Production Ready**

| Service | Username | Password |- Monitoring & observability

|---------|----------|----------|- Security & compliance

| Database | `dryfruits_user` | `dryfruits_pass123` |- Disaster recovery

| RabbitMQ | `admin` | `admin123` |- Multi-region deployment



## 📊 Service Ports## 📊 **Architecture Diagram**



| Service | Port | Description |```

|---------|------|-------------|                    ┌─────────────────┐

| Customer Portal | 3000 | Public e-commerce interface |                    │   API Gateway   │

| Admin Dashboard | 3001 | Internal management system |                    └─────────────────┘

| Eureka Server | 8761 | Service discovery |                             │

| Inventory Service | 8084 | Product management API |        ┌────────────────────┼────────────────────┐

| Shipping Service | 8085 | Order fulfillment API |        │                    │                    │

| PostgreSQL | 5432 | Database |┌───────────────┐   ┌─────────────────┐   ┌──────────────┐

| Redis | 6379 | Cache |│  User Service │   │ Product Service │   │Order Service │

| RabbitMQ | 5672/15672 | Message broker |└───────────────┘   └─────────────────┘   └──────────────┘

        │                    │                    │

## 🛠️ Management Commands        └────────────────────┼────────────────────┘

                             │

```bash                    ┌─────────────────┐

# Check status                    │     Kafka       │

docker ps                    │  Message Bus    │

                    └─────────────────┘

# View logs                             │

docker logs [service-name]    ┌────────────────────────┼────────────────────────┐

    │                        │                        │

# Restart service┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐

docker-compose -f docker-compose-light.yml restart [service-name]│Payment      │    │  Inventory      │    │   Shipping      │

│Service      │    │  Service        │    │   Service       │

# Stop all services└─────────────┘    └─────────────────┘    └─────────────────┘

docker-compose -f docker-compose-light.yml down```

docker-compose -f frontend-only.yml down

## 🚀 **Quick Start**

# Clean up

docker-compose -f docker-compose-light.yml down -v### **Docker Desktop:**

docker system prune -f```bash

```# Build all services

./build-all.sh

## 📚 Complete Documentation

# Start with Docker Compose

For detailed system documentation, configuration, API references, and troubleshooting guide, see:docker-compose up -d

**[SYSTEM_DOCUMENTATION.md](SYSTEM_DOCUMENTATION.md)**

# Scale services

## 🎯 Featuresdocker-compose up -d --scale order-service=3

```

### Customer Portal

- 🛍️ Product catalog browsing### **Kubernetes:**

- 🛒 Shopping cart management```bash

- 📦 Order tracking# Deploy to K8s

- 👤 User account managementkubectl apply -f k8s/

- 📱 Responsive design

# Check status

### Admin Dashboardkubectl get pods -n dry-fruits

- 📊 Analytics and KPIs

- 📦 Inventory management# Scale services

- 🚚 Shipping managementkubectl scale deployment order-service --replicas=5

- 👥 Order processing```

- 🔧 System monitoring

Ready to build the complete production-grade platform!
### Backend Services
- 🔍 Service discovery (Eureka)
- 🏪 Inventory management
- 🚚 Shipping coordination
- 💾 Data persistence
- 🔄 Message queuing

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│  Customer       │    │  Admin          │
│  Portal :3000   │    │  Dashboard :3001│
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌─────────────────┐
         │  Eureka Server  │
         │     :8761       │
         └─────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌─────────┐  ┌─────────────┐  ┌─────────────┐
│Inventory│  │  Shipping   │  │ PostgreSQL  │
│ :8084   │  │   :8085     │  │   :5432     │
└─────────┘  └─────────────┘  └─────────────┘
    │                │                │
    └────────────────┼────────────────┘
                     │
         ┌─────────────────┐
         │  Redis :6379    │
         │ RabbitMQ :5672  │
         └─────────────────┘
```

## 📞 Support

For issues, questions, or contributions, please refer to the troubleshooting section in the system documentation.

---

**Ready to start exploring your dry fruits microservices platform!** 🎉