# 📊 Observability Stack - Complete Guide

## ✅ All Observability Tools Running

**Last Updated**: December 19, 2025  
**Status**: 🟢 All tools operational with external routes

---

## 🌐 Observability Dashboard URLs

### 📊 Grafana (Visualization & Dashboards)
```
https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Default Credentials:**
- Username: `admin`
- Password: `grafana123`

**Features:**
- ✅ Pre-configured Dry Fruits Platform dashboard
- ✅ Service health metrics
- ✅ HTTP request rates
- ✅ Error rates and response times
- ✅ Database connections
- ✅ Custom alerts

**Available Dashboards:**
1. **🥜 Dry Fruits Platform - System Overview**
   - Service status (UP/DOWN)
   - HTTP request rates
   - Error rates
   - Response times
   - Active connections

---

### 📈 Prometheus (Metrics Collection)
```
https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Features:**
- ✅ Metrics scraping from all services
- ✅ Service discovery integration
- ✅ PromQL query interface
- ✅ Alerting rules
- ✅ Target health monitoring

**Key Metrics Available:**
- `up` - Service availability (1=UP, 0=DOWN)
- `http_server_requests_seconds_count` - Request count
- `http_server_requests_seconds_sum` - Total response time
- `jvm_memory_used_bytes` - Java memory usage
- `system_cpu_usage` - CPU usage
- `hikaricp_connections_active` - Database connections
- `process_uptime_seconds` - Service uptime

**Useful Queries:**
```promql
# Service availability
up{job="user-service"}

# Request rate (requests per second)
rate(http_server_requests_seconds_count[1m])

# Average response time
rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m])

# Error rate
rate(http_server_requests_seconds_count{status=~"5.."}[1m])

# CPU usage
system_cpu_usage

# Memory usage
jvm_memory_used_bytes{area="heap"}
```

---

### 🔍 Jaeger (Distributed Tracing)
```
https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Features:**
- ✅ End-to-end request tracing
- ✅ Service dependency map
- ✅ Latency analysis
- ✅ Error tracing
- ✅ Performance bottleneck detection

**Use Cases:**
1. **Trace Checkout Flow:**
   - Customer Portal → User Service → Payment Service
   - See exact timing for each step
   - Identify slow services

2. **Debug Failed Requests:**
   - View complete request path
   - See error stack traces
   - Identify which service failed

3. **Performance Analysis:**
   - Compare response times
   - Find bottlenecks
   - Optimize slow queries

---

## 🔧 How to Use Observability Stack

### 1. Access Grafana Dashboard

**Step 1:** Open Grafana URL in browser
```
https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Step 2:** Accept SSL certificate
- Click "Advanced"
- Click "Proceed to grafana-route..."

**Step 3:** Login
- Username: `admin`
- Password: `grafana123`

**Step 4:** View Dashboard
- Go to "Dashboards" → "Browse"
- Open "🥜 Dry Fruits Platform - System Overview"

**What You'll See:**
- ✅ Service status indicators (Green = UP, Red = DOWN)
- 📊 Real-time request rates
- ⏱️ Response time graphs
- ❌ Error rate trending
- 💾 Database connection pools
- 🔥 CPU and memory usage

---

### 2. Query Metrics with Prometheus

**Step 1:** Open Prometheus URL
```
https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Step 2:** Check Targets
- Go to "Status" → "Targets"
- Verify all services are being scraped
- Should show "UP" status

**Step 3:** Run Queries
- Go to "Graph" tab
- Enter PromQL query
- Click "Execute"

**Example Queries:**

**Check if user-service is up:**
```
up{job="user-service"}
```

**Get request count for last 5 minutes:**
```
increase(http_server_requests_seconds_count{uri="/api/v1/users/health"}[5m])
```

**Calculate 95th percentile response time:**
```
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))
```

---

### 3. Trace Requests with Jaeger

**Step 1:** Open Jaeger URL
```
https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Step 2:** Select Service
- Choose service from dropdown (e.g., "user-service")

**Step 3:** Find Traces
- Click "Find Traces"
- View recent traces

**Step 4:** Analyze Trace
- Click on a trace to see details
- View span timeline
- Check individual service calls
- Identify slow operations

---

## 🚨 Error Detection & Alerting

### Built-in Error Detection

**1. Prometheus Alerts**
- Service down alerts
- High error rate alerts
- High response time alerts
- Memory/CPU threshold alerts

**2. Grafana Alerts**
- Visual alerts on dashboards
- Configurable thresholds
- Multiple notification channels

**3. Synthetic Monitoring**
- Active endpoint monitoring
- Automated health checks
- Error logging

---

## 🤖 Synthetic Monitoring Script

### Enhanced Monitoring Tool

We've created a comprehensive synthetic monitoring script:

```powershell
.\synthetic-monitor-enhanced.ps1
```

**Features:**
- ✅ Tests all frontend pages
- ✅ Tests all backend services
- ✅ Checks health endpoints
- ✅ Simulates user authentication flow
- ✅ Tests complete e-commerce journey
- ✅ Monitors observability stack itself
- ✅ Generates statistics and error reports
- ✅ Continuous or timed monitoring

**Usage Examples:**

**1. Run for 60 minutes (default):**
```powershell
.\synthetic-monitor-enhanced.ps1
```

**2. Continuous monitoring:**
```powershell
.\synthetic-monitor-enhanced.ps1 -Continuous
```

**3. Custom duration and interval:**
```powershell
.\synthetic-monitor-enhanced.ps1 -DurationMinutes 120 -IntervalSeconds 60
```

**What It Tests:**
- ✅ Customer Portal homepage
- ✅ Admin Dashboard
- ✅ User Service (root, health, actuator, info)
- ✅ Payment Service (root, health, test cards)
- ✅ User authentication endpoints
- ✅ Complete checkout flow
- ✅ Grafana dashboard
- ✅ Prometheus metrics
- ✅ Jaeger tracing UI

**Output:**
```
✅ Customer Portal Homepage [200] 245ms
✅ User Service Root [200] 156ms
✅ Payment Service Health [200] 123ms
⚠️  Payment Service Root [Expected content not found]
❌ Admin Dashboard [ERROR] 5021ms - Connection timeout

📈 MONITORING STATISTICS
Runtime:         5.3 minutes
Total Checks:    127
Successful:      119 (93.7%)
Failed:          8
Success Rate:    93.7% ⚠️
```

---

## 🧪 Testing Scenarios

### Scenario 1: Monitor Normal Operations

**Goal:** Verify all services are healthy

**Steps:**
1. Open Grafana dashboard
2. Check all service status panels show "UP"
3. Verify request rates are within normal range
4. Check error rate is < 1%

**Expected Results:**
- All services: 🟢 Green
- Request rate: Steady
- Error rate: < 1%
- Response time: < 500ms

---

### Scenario 2: Detect Service Failure

**Goal:** Identify when a service goes down

**Steps:**
1. Run synthetic monitoring
2. Simulate failure (scale pod to 0)
3. Watch Grafana dashboard
4. Check Prometheus alerts

**Expected Detections:**
- Grafana: Service status changes to RED
- Prometheus: `up` metric = 0
- Synthetic Monitor: ❌ Failed checks
- Jaeger: No new traces from failed service

---

### Scenario 3: Trace Complete User Journey

**Goal:** Track a user from login to payment

**Steps:**
1. Open Customer Portal
2. Login with test user
3. Add items to cart
4. Complete checkout
5. Open Jaeger
6. Search for traces with operation "checkout"
7. Analyze the trace

**What You'll See:**
```
Customer Portal (Frontend)
  └─> User Service (Authentication) - 120ms
  └─> Payment Service (Process Payment) - 1200ms
      └─> PostgreSQL (Database Query) - 50ms
      └─> Payment Gateway (Mock) - 1000ms

Total: 1370ms
```

---

### Scenario 4: Find Performance Bottlenecks

**Goal:** Identify slow operations

**Steps:**
1. Open Prometheus
2. Run query for p95 response times:
   ```
   histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))
   ```
3. Identify services with high latency
4. Open Jaeger
5. Find slow traces
6. Analyze span durations

---

## 📊 Dashboard Panels Explained

### 1. Service Status Panel
- **What it shows:** Current UP/DOWN status of each service
- **Colors:** 
  - 🟢 Green = Service UP (healthy)
  - 🔴 Red = Service DOWN (failed)
- **Alert if:** Any service shows RED

### 2. HTTP Request Rate Panel
- **What it shows:** Requests per second for each service
- **Normal range:** 1-100 req/s (depends on traffic)
- **Alert if:** Sudden drop to 0 (service down) or unexpected spike

### 3. Error Rate Panel
- **What it shows:** Percentage of requests returning errors (4xx, 5xx)
- **Normal range:** < 1%
- **Alert if:** > 5% error rate

### 4. Response Time Panel
- **What it shows:** Average response time in milliseconds
- **Normal range:** 
  - Frontend: < 200ms
  - Backend APIs: < 500ms
  - Database queries: < 100ms
- **Alert if:** > 2000ms

### 5. Database Connections Panel
- **What it shows:** Active database connections
- **Normal range:** 5-20 active connections
- **Alert if:** Pool exhausted or no connections

---

## 🔔 Alert Configuration

### Creating Custom Alerts in Grafana

**Step 1:** Edit Dashboard Panel
- Click panel title → "Edit"

**Step 2:** Go to Alert Tab
- Click "Alert" tab

**Step 3:** Define Alert Rule
```
WHEN avg() OF query(A, 5m, now) IS ABOVE 1000
```

**Step 4:** Configure Notifications
- Add notification channel
- Set alert message

**Example Alerts:**

**1. Service Down Alert**
```
Alert: user-service is DOWN
Condition: up{job="user-service"} == 0
Duration: 1m
Action: Send notification
```

**2. High Error Rate Alert**
```
Alert: Payment service error rate high
Condition: rate(http_server_requests_seconds_count{status=~"5..",service="payment-service"}[5m]) > 0.05
Duration: 5m
Action: Send notification
```

**3. High Response Time Alert**
```
Alert: Checkout is slow
Condition: histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{uri="/checkout"}[5m])) > 2
Duration: 10m
Action: Send notification
```

---

## 📱 Notification Channels

### Supported Channels
1. **Email** - Send alerts via email
2. **Slack** - Post to Slack channel
3. **Webhook** - HTTP POST to custom endpoint
4. **PagerDuty** - Create PagerDuty incidents

### Setup Example (Email)

1. Go to "Alerting" → "Notification channels"
2. Click "New channel"
3. Choose "Email"
4. Enter email addresses
5. Test and save

---

## ✅ Observability Checklist

### Daily Checks
- [ ] Open Grafana dashboard
- [ ] Verify all services show "UP"
- [ ] Check error rate < 1%
- [ ] Verify response times normal
- [ ] Run synthetic monitoring for 10 minutes

### Weekly Checks
- [ ] Review Prometheus targets
- [ ] Check disk space for metrics storage
- [ ] Review Jaeger traces for patterns
- [ ] Update alert thresholds if needed
- [ ] Clean up old traces/logs

### When Issues Occur
- [ ] Check Grafana for which service is down
- [ ] Query Prometheus for detailed metrics
- [ ] Use Jaeger to trace failed requests
- [ ] Review synthetic monitor error logs
- [ ] Check OpenShift pod logs

---

## 🎯 Quick Commands

### Check Observability Pods
```powershell
oc get pods -n dry-fruits-platform | Select-String "grafana|prometheus|jaeger"
```

### View Grafana Logs
```powershell
oc logs deployment/grafana -n dry-fruits-platform --tail=100
```

### View Prometheus Logs
```powershell
oc logs deployment/prometheus -n dry-fruits-platform --tail=100
```

### Test Observability Routes
```powershell
# Grafana
curl -k https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

# Prometheus
curl -k https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

# Jaeger
curl -k https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

---

## 📊 Service Status

| Tool | Status | Route | Purpose |
|------|--------|-------|---------|
| Grafana | 🟢 Running | grafana-route | Dashboards & Visualization |
| Prometheus | 🟢 Running | prometheus-route | Metrics Collection |
| Jaeger | 🟢 Running | jaeger-route | Distributed Tracing |

---

## 🚀 Summary

**Your observability stack is fully operational!**

**What You Have:**
- ✅ Grafana with pre-built dashboard
- ✅ Prometheus collecting metrics
- ✅ Jaeger tracing requests
- ✅ External routes for all tools
- ✅ Synthetic monitoring script
- ✅ Error detection and alerting

**How to Start:**
1. Open Grafana dashboard
2. Run synthetic monitoring script
3. Monitor your platform in real-time!

**All URLs:**
- Grafana: https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
- Prometheus: https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
- Jaeger: https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

**Happy Monitoring!** 📊🎉
