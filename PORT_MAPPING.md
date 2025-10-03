# Dry Fruits Microservices - Port Mapping Design

## Current Port Conflicts
- **Grafana**: Port 3000 (LoadBalancer)
- **Customer Portal**: Port 3000 internal (LoadBalancer) 
- **Admin Dashboard**: Port 3000 internal (LoadBalancer)

## Proposed Port Allocation

### Frontend Services (LoadBalancer - Direct Access)
| Service | Internal Port | External Port | LoadBalancer Port | Access URL |
|---------|---------------|---------------|-------------------|------------|
| Customer Portal | 3000 | 80 | 30900 | http://localhost:30900 |
| Admin Dashboard | 3001 | 80 | 31059 | http://localhost:31059 |

### Observability Services (LoadBalancer - Direct Access)
| Service | Internal Port | External Port | LoadBalancer Port | Access URL |
|---------|---------------|---------------|-------------------|------------|
| Grafana | 3000 | 3000 | 30412 | http://localhost:30412 |
| Jaeger UI | 16686 | 16686 | - | Port Forward: 16686:16686 |
| Prometheus | 9090 | 9090 | - | Port Forward: 9090:9090 |

### Backend Services (ClusterIP - Port Forward Access)
| Service | Internal Port | Service Port | Port Forward | Access URL |
|---------|---------------|--------------|--------------|------------|
| Eureka Server | 8761 | 8761 | 8761:8761 | http://localhost:8761 |
| Inventory Service | 8082 | 8082 | 8082:8082 | http://localhost:8082 |
| Shipping Service | 8083 | 8083 | 8083:8083 | http://localhost:8083 |

### Data Services (ClusterIP - Internal Only)
| Service | Internal Port | Service Port | Purpose |
|---------|---------------|--------------|---------|
| PostgreSQL | 5432 | 5432 | Database |
| Redis | 6379 | 6379 | Cache |
| RabbitMQ | 5672, 15672 | 5672, 15672 | Message Queue |

## Fix Required
1. Change Admin Dashboard internal port from 3000 to 3001
2. Update service configuration to use proper targetPort
3. Rebuild admin-dashboard Docker image with port 3001