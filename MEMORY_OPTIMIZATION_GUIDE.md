# 🎯 **8GB RAM Optimized Docker Compose**

## 💾 **Memory Requirements Analysis:**

### **Current Full Stack (Too Heavy for 8GB):**
- 6 PostgreSQL databases: ~1.2GB
- 6 Spring Boot services: ~3GB  
- RabbitMQ: ~512MB
- Redis: ~256MB
- **Total: ~5GB+ (Manageable but tight)**

### **⚡ Optimized Version for 8GB RAM:**

```yaml
# docker-compose-light.yml
services:
  # Single shared database (saves ~800MB)
  postgres-shared:
    image: postgres:15-alpine
    container_name: postgres-shared
    environment:
      POSTGRES_DB: dryfruits_db
      POSTGRES_USER: dryfruits_user
      POSTGRES_PASSWORD: dryfruits_pass123
    ports:
      - "5432:5432"
    volumes:
      - postgres_shared_data:/var/lib/postgresql/data
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  # Lightweight cache
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 128M

  # Message queue
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: admin123
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M

  # Essential services only
  eureka-server:
    build:
      context: ./services/eureka-server
      dockerfile: Dockerfile
    container_name: eureka-server
    ports:
      - "8761:8761"
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  # Core business services
  inventory-service:
    build:
      context: ./services/inventory-service
      dockerfile: Dockerfile
    container_name: inventory-service
    ports:
      - "8084:8084"
    depends_on:
      - postgres-shared
      - rabbitmq
      - redis
      - eureka-server
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-shared:5432/dryfruits_db
      - SPRING_DATASOURCE_USERNAME=dryfruits_user
      - SPRING_DATASOURCE_PASSWORD=dryfruits_pass123
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_RABBITMQ_HOST=rabbitmq
      - SPRING_REDIS_HOST=redis
      - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://eureka-server:8761/eureka/
      - JAVA_OPTS=-Xms256m -Xmx512m
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 768M
        reservations:
          memory: 512M

  shipping-service:
    build:
      context: ./services/shipping-service
      dockerfile: Dockerfile
    container_name: shipping-service
    ports:
      - "8085:8085"
    depends_on:
      - postgres-shared
      - rabbitmq
      - redis
      - eureka-server
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-shared:5432/dryfruits_db
      - SPRING_DATASOURCE_USERNAME=dryfruits_user
      - SPRING_DATASOURCE_PASSWORD=dryfruits_pass123
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_RABBITMQ_HOST=rabbitmq
      - SPRING_REDIS_HOST=redis
      - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://eureka-server:8761/eureka/
      - JAVA_OPTS=-Xms256m -Xmx512m
    networks:
      - dryfruits-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 768M
        reservations:
          memory: 512M

networks:
  dryfruits-network:
    driver: bridge

volumes:
  postgres_shared_data:
```

## 📊 **Optimized Memory Usage:**
- PostgreSQL (shared): ~512MB
- 2 Spring Boot services: ~1.5GB
- RabbitMQ: ~512MB  
- Redis: ~128MB
- Eureka: ~512MB
- **Total: ~3.2GB (Perfect for 8GB RAM!)**

## 🚀 **How to Run on 8GB RAM:**

1. **Use the optimized version:**
```powershell
# Use the lightweight compose file
docker-compose -f docker-compose-light.yml up -d
```

2. **Start services gradually:**
```powershell
# Start infrastructure first
docker-compose up -d postgres-shared redis rabbitmq eureka-server

# Wait 30 seconds, then start business services
docker-compose up -d inventory-service shipping-service
```

3. **Monitor memory usage:**
```powershell
# Check memory usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
```