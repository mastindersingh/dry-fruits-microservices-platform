# 🥜 Dry Fruits Microservices Platform

A simplified, focused microservices platform for dry fruits e-commerce with clean architecture and easy deployment.

## 🎯 **Simplified Architecture - Core Services Only**

### **Core Microservices:**
1. **API Gateway** - Routes requests, load balancing
2. **User Service** - Customer & authentication management  
3. **Product Service** - Product catalog with Redis caching
4. **Order Service** - Order processing & workflow
5. **Payment Service** - Payment processing
6. **Inventory Service** - Stock tracking & management
7. **Shipping Service** - Logistics & delivery

### **Infrastructure Services:**
8. **Eureka Server** - Service discovery & registration
9. **PostgreSQL** - Main database for all services
10. **Redis** - Caching layer for product service
11. **RabbitMQ** - Message queue for service communication

### **Frontend Applications:**
12. **Customer Portal** - Customer-facing web application
13. **Admin Dashboard** - Administrative interface

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- 4GB+ RAM recommended  
- 5GB+ free disk space

### One-Command Setup

**Windows (PowerShell):**
```powershell
.\setup-simple.ps1
```

**Windows (CMD):**
```cmd
setup-simple.bat
```

### What Gets Started:
- ✅ PostgreSQL database
- ✅ Redis cache  
- ✅ RabbitMQ message queue
- ✅ All 7 microservices
- ✅ Frontend applications
- ✅ Service discovery

## 🌐 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **API Gateway** | http://localhost:8080 | Main API endpoint |
| **Customer Portal** | http://localhost:3000 | Customer interface |
| **Admin Dashboard** | http://localhost:3001 | Admin interface |
| **Eureka Server** | http://localhost:8761 | Service registry |
| **RabbitMQ Admin** | http://localhost:15672 | Queue management (admin/admin123) |

## 📊 System Status

Check platform health:
```powershell
.\status-check.ps1
```

## 🛠 Common Operations

### View Logs
```bash
# All services
docker-compose -f docker-compose-simple.yml logs -f

# Specific service
docker-compose -f docker-compose-simple.yml logs -f user-service
```

### Restart Services
```bash
# Restart all
docker-compose -f docker-compose-simple.yml restart

# Restart specific service
docker-compose -f docker-compose-simple.yml restart user-service
```

### Stop Everything
```bash
docker-compose -f docker-compose-simple.yml down
```

### Rebuild After Code Changes
```bash
docker-compose -f docker-compose-simple.yml up -d --build
```

## 🗃 Database Schema

All services share a single PostgreSQL database with separate schemas:
- `users` - User management data
- `products` - Product catalog  
- `orders` - Order processing
- `inventory` - Stock levels
- `payments` - Payment records
- `shipping` - Delivery tracking

## 🔧 Configuration

Environment variables are managed in `.env` file:
- Database credentials
- Redis configuration  
- RabbitMQ settings
- JWT secrets
- Logging levels

## 📁 Project Structure

```
dry-fruits-microservices-platform/
├── services/                    # Microservices
│   ├── api-gateway/
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   ├── payment-service/
│   ├── inventory-service/
│   └── shipping-service/
├── frontend/                    # Web applications
│   ├── customer-portal/
│   └── admin-dashboard/
├── docker-compose-simple.yml    # Main deployment
├── .env                        # Configuration
├── setup-simple.ps1           # Setup script
└── status-check.ps1           # Health check
```

## 🔍 Troubleshooting

### Common Issues:

1. **Port conflicts**: Ensure ports 3000, 3001, 5432, 6379, 8080, 8761, 15672 are free
2. **Memory issues**: Increase Docker memory to 4GB+
3. **Build failures**: Run `docker system prune` to clean up

### Debug Commands:
```bash
# Check container status
docker-compose -f docker-compose-simple.yml ps

# Check specific service logs
docker-compose -f docker-compose-simple.yml logs user-service

# Connect to database
docker exec -it postgres-main psql -U dry_fruits_user -d dry_fruits_db

# Check Redis
docker exec -it redis-cache redis-cli
```

## 🚀 Next Steps

Once the basic platform is stable, you can:
1. Add observability stack (Prometheus, Grafana)
2. Implement API documentation (Swagger)
3. Add security scanning
4. Deploy to Kubernetes
5. Add CI/CD pipeline

## 📝 API Documentation

API documentation is available at:
- Swagger UI: http://localhost:8080/swagger-ui.html
- API Docs: http://localhost:8080/v3/api-docs

## 🤝 Contributing

1. Focus on core functionality first
2. Keep services simple and focused
3. Follow Spring Boot best practices
4. Test locally before committing

---

**Note**: This is a simplified version focusing on core microservices functionality. Observability and monitoring features have been removed to reduce complexity and improve stability.