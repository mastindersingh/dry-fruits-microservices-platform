# 🚀 Running Dry Fruits Platform WITHOUT Docker

Since Docker Desktop isn't available, here's how to run the services directly with Java.

## Prerequisites
- Java 17+ installed
- Maven installed (or use the included mvnw)

## Step-by-Step Local Setup

### 1. Start Infrastructure Services Manually

You'll need to install and run these locally:

**PostgreSQL:**
- Download from https://www.postgresql.org/download/windows/
- Install and create database: `dry_fruits_db`
- User: `dry_fruits_user`, Password: `dry_fruits_pass123`

**Redis (Optional for now):**
- Download from https://github.com/microsoftarchive/redis/releases
- Or skip Redis and disable caching in product service

**RabbitMQ (Optional for now):**
- Download from https://www.rabbitmq.com/download.html
- Or skip messaging features for now

### 2. Start Services in Order

**Terminal 1 - Eureka Server (Service Discovery):**
```bash
cd services/eureka-server
./mvnw spring-boot:run
# Access: http://localhost:8761
```

**Terminal 2 - User Service:**
```bash
cd services/user-service
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
# Will run on random port, check console for port
```

**Terminal 3 - Product Service:**
```bash
cd services/product-service
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

**Terminal 4 - API Gateway:**
```bash
cd services/api-gateway
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
# Access: http://localhost:8080
```

**Terminal 5 - Order Service:**
```bash
cd services/order-service
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

### 3. Access Frontend

**Terminal 6 - Customer Portal:**
```bash
cd frontend/customer-portal
npm install
npm start
# Access: http://localhost:3000
```

**Terminal 7 - Admin Dashboard:**
```bash
cd frontend/admin-dashboard
npm install
npm start
# Access: http://localhost:3001
```

## Quick Test (Minimal Setup)

If you want to test just the core functionality:

1. **Start only Eureka Server:**
   ```bash
   cd services/eureka-server
   ./mvnw spring-boot:run
   ```

2. **Start User Service with H2 Database (no PostgreSQL needed):**
   ```bash
   cd services/user-service
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=h2
   ```

3. **Start API Gateway:**
   ```bash
   cd services/api-gateway  
   ./mvnw spring-boot:run
   ```

## Environment Setup for Local Development

Create these application-local.yml files in each service's `src/main/resources/`:

**services/user-service/src/main/resources/application-local.yml:**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  h2:
    console:
      enabled: true
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: create-drop

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka

server:
  port: 8081
```

## Alternative: Use Docker Desktop

**Best Option:** Install Docker Desktop for Windows:
1. Download from https://www.docker.com/products/docker-desktop
2. Install and restart
3. Run `.\setup-simple.ps1`

This will give you the full containerized experience with all infrastructure services.

## Next Steps

Once you get Docker Desktop installed, you can use the full containerized setup which is much easier to manage!