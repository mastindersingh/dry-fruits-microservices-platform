# 🔭 Complete Observability Stack Documentation

## Overview

Your Dry Fruits Platform now includes enterprise-grade observability with **Prometheus**, **Grafana**, **Jaeger**, and **OpenTelemetry** integration for **Datadog**, **Splunk**, **Elastic APM**, and other platforms.

---

## 🎯 **What Each Tool Does**

### **🔥 Prometheus - Metrics Collection**
- **Purpose**: Time-series database for metrics
- **URL**: http://localhost:9090
- **Collects**: CPU, memory, HTTP requests, database connections, custom business metrics
- **Data Sources**: All microservices, infrastructure components, containers

### **📈 Grafana - Visualization & Dashboards** 
- **Purpose**: Beautiful dashboards and alerting
- **URL**: http://localhost:3300
- **Credentials**: `admin` / `grafana123`
- **Features**: Pre-built dashboards, custom queries, alert notifications
- **Connects to**: Prometheus, Jaeger, Loki, external data sources

### **🕵️ Jaeger - Distributed Tracing**
- **Purpose**: Track requests across microservices
- **URL**: http://localhost:16686
- **Shows**: Request flow, performance bottlenecks, error propagation
- **Integrates**: OpenTelemetry automatic instrumentation

### **🔭 OpenTelemetry Collector - Universal Gateway**
- **Purpose**: Receive, process, and export telemetry data
- **gRPC Endpoint**: http://localhost:4317
- **HTTP Endpoint**: http://localhost:4318
- **Exports to**: Jaeger, Prometheus, Datadog, Splunk, Elastic, New Relic

### **🚨 AlertManager - Alert Management**
- **Purpose**: Handle alerts from Prometheus
- **URL**: http://localhost:9093
- **Features**: Alert routing, grouping, silencing, notifications

### **📋 Loki - Log Aggregation**
- **Purpose**: Centralized logging like Elasticsearch
- **URL**: http://localhost:3100
- **Features**: Log queries, correlation with metrics and traces

---

## 📊 **Access Credentials & URLs**

| Service | URL | Username | Password | Purpose |
|---------|-----|----------|----------|---------|
| **Grafana** | http://localhost:3300 | `admin` | `grafana123` | Dashboards & Visualization |
| **Prometheus** | http://localhost:9090 | - | - | Metrics & Queries |
| **Jaeger** | http://localhost:16686 | - | - | Distributed Tracing |
| **AlertManager** | http://localhost:9093 | - | - | Alert Management |
| **Loki** | http://localhost:3100 | - | - | Log Aggregation |
| **cAdvisor** | http://localhost:8080 | - | - | Container Metrics |
| **Node Exporter** | http://localhost:9100 | - | - | System Metrics |
| **OTEL Collector** | http://localhost:4317/4318 | - | - | Telemetry Gateway |

---

## 🚀 **Quick Start Commands**

### **Start Full Observability Stack**
```bash
# Windows
setup-enhanced.bat

# Linux/Mac
chmod +x setup-enhanced.sh
./setup-enhanced.sh
```

### **Start Only Observability (without app)**
```bash
docker-compose -f docker-compose-observability.yml up -d
```

### **Check All Services Status**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### **View Service Logs**
```bash
# Application logs
docker logs inventory-service -f

# Observability logs
docker logs grafana -f
docker logs prometheus -f
docker logs jaeger -f
```

---

## 📡 **External Platform Integration**

### **🏢 Enterprise Platforms Supported**

#### **Datadog Integration**
```bash
# Set environment variables in .env.observability
DATADOG_API_KEY=your_api_key_here
DATADOG_SITE=datadoghq.com

# Data automatically flows to Datadog APM, Infrastructure, Logs
```

#### **Splunk Integration**
```bash
# Configure HEC (HTTP Event Collector)
SPLUNK_HEC_URL=https://your-instance.splunkcloud.com:8088/services/collector
SPLUNK_HEC_TOKEN=your_token_here

# Logs and metrics sent to Splunk automatically
```

#### **Elastic APM Integration**
```bash
# Configure Elastic Cloud
ELASTIC_APM_SERVER_URL=https://your-deployment.apm.region.aws.cloud.es.io:443
ELASTIC_APM_SECRET_TOKEN=your_token_here

# APM data flows to Elasticsearch/Kibana
```

#### **New Relic Integration**
```bash
# Configure New Relic
NEW_RELIC_LICENSE_KEY=your_license_key_here

# All telemetry data sent to New Relic One
```

---

## 🎛️ **Configuration Files**

### **Key Configuration Files:**
- `observability/prometheus/prometheus.yml` - Metrics collection config
- `observability/grafana/provisioning/` - Grafana datasources & dashboards
- `observability/otel/otel-collector-config.yml` - OTEL routing & export config
- `observability/alertmanager/alertmanager.yml` - Alert routing & notifications
- `.env.observability` - External platform credentials

### **Service Discovery:**
Prometheus automatically discovers and monitors:
- ✅ All Java microservices (`/actuator/prometheus`)
- ✅ Frontend applications 
- ✅ Infrastructure (Postgres, Redis, RabbitMQ)
- ✅ Container metrics (cAdvisor)
- ✅ System metrics (node-exporter)

---

## 🎨 **Pre-Built Dashboards**

### **Grafana Dashboards Available:**
1. **🥜 Dry Fruits Platform Overview** - System health, request rates, response times
2. **🔥 Infrastructure Dashboard** - CPU, memory, disk, network
3. **🐳 Container Metrics** - Docker container performance
4. **📊 Business Metrics** - Custom application KPIs
5. **🚨 Alert Dashboard** - Active alerts and their status

### **Key Metrics Tracked:**
- **Performance**: Response times, throughput, error rates
- **Infrastructure**: CPU, memory, disk usage, network I/O
- **Business**: Orders processed, inventory levels, customer activity
- **Health**: Service availability, database connections, queue depth

---

## 🚨 **Alerting & Notifications**

### **Pre-Configured Alerts:**
- 🔴 **Service Down** - Any service unavailable > 2 minutes
- 🟡 **High CPU Usage** - CPU > 80% for 5 minutes
- 🟡 **High Memory Usage** - Memory > 85% for 5 minutes
- 🔴 **High Disk Usage** - Disk > 90% for 5 minutes
- 🟡 **Database Connections High** - Connection pool > 80%
- 🟡 **High Response Time** - 95th percentile > 2 seconds

### **Notification Channels:**
Configure in `.env.observability`:
- **Slack**: Real-time alert notifications
- **Email**: Critical alert summaries
- **PagerDuty**: Incident management integration
- **Webhook**: Custom integrations

---

## 📈 **Custom Metrics & Traces**

### **Adding Custom Business Metrics:**
```java
// In your Java services
@Component
public class BusinessMetrics {
    private final Counter ordersProcessed = Counter.builder("orders_processed_total")
        .description("Total orders processed")
        .register(Metrics.globalRegistry);
    
    private final Timer orderProcessingTime = Timer.builder("order_processing_duration")
        .description("Order processing time")
        .register(Metrics.globalRegistry);
        
    public void recordOrderProcessed() {
        ordersProcessed.increment();
    }
    
    public void recordProcessingTime(Duration duration) {
        orderProcessingTime.record(duration);
    }
}
```

### **Custom Tracing:**
```java
// Automatic tracing via OpenTelemetry
@Service
public class InventoryService {
    
    @Traced  // Automatically creates spans
    public Product findProduct(String id) {
        // Your business logic
        return productRepository.findById(id);
    }
    
    // Manual span creation for complex operations
    public void complexOperation() {
        Span span = tracer.nextSpan()
            .name("complex-inventory-operation")
            .tag("operation.type", "inventory")
            .start();
        
        try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
            // Your complex logic here
        } finally {
            span.end();
        }
    }
}
```

---

## 🔧 **Troubleshooting**

### **Common Issues:**

#### **Services Not Showing in Prometheus**
```bash
# Check if service is exposing metrics
curl http://localhost:8084/inventory/v1/actuator/prometheus

# Check Prometheus targets
# Go to http://localhost:9090/targets
```

#### **No Traces in Jaeger**
```bash
# Check OTEL collector logs
docker logs otel-collector

# Verify OTEL endpoint in service config
# Should be: http://otel-collector:4317
```

#### **Grafana Dashboards Empty**
```bash
# Check if Prometheus datasource is working
# Go to Grafana > Configuration > Data Sources > Test

# Verify metrics are being collected
# Go to Prometheus > Graph > Query: up
```

#### **External Platform Not Receiving Data**
```bash
# Check environment variables
cat .env.observability

# Check OTEL collector export configuration
docker logs otel-collector | grep -i "export"
```

---

## 🎯 **Production Recommendations**

### **Resource Requirements:**
- **Minimum**: 8GB RAM, 4 CPU cores, 50GB disk
- **Recommended**: 16GB RAM, 8 CPU cores, 100GB disk
- **High Load**: 32GB RAM, 16 CPU cores, 200GB+ disk

### **Data Retention:**
- **Prometheus**: 15 days (configurable)
- **Jaeger**: 7 days (configurable)
- **Loki**: 30 days (configurable)

### **Security:**
- Enable authentication for Grafana
- Configure HTTPS for external access
- Use secrets management for API keys
- Implement network policies for container isolation

### **High Availability:**
- Run multiple instances of each service
- Use external storage (not local volumes)
- Implement load balancing
- Configure backup strategies

---

## 📚 **Additional Resources**

### **Documentation Links:**
- [Prometheus Query Language](https://prometheus.io/docs/prometheus/latest/querying/)
- [Grafana Dashboard Guide](https://grafana.com/docs/grafana/latest/dashboards/)
- [Jaeger Tracing Guide](https://www.jaegertracing.io/docs/latest/)
- [OpenTelemetry Java](https://opentelemetry.io/docs/instrumentation/java/)

### **Useful Queries:**
```promql
# Service availability
up

# Request rate per service
sum(rate(http_server_requests_seconds_count[5m])) by (job)

# Error rate
sum(rate(http_server_requests_seconds_count{status=~"4..|5.."}[5m])) by (job) / sum(rate(http_server_requests_seconds_count[5m])) by (job) * 100

# 95th percentile response time
histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket[5m])) by (le, job))

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

**🎉 Your observability stack is now enterprise-ready with full telemetry, monitoring, alerting, and integration capabilities!**