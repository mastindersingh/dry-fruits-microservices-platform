# 📊 Observability Stack - Quick Start

## ✅ All Tools Configured & Working

**Status**: 🟢 Fully Operational

---

## 🌐 Access URLs (Accept SSL Certificates)

### Grafana Dashboard
```
https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```
**Login**: admin / grafana123  
**Pre-built Dashboard**: "🥜 Dry Fruits Platform - System Overview"

### Prometheus Metrics
```
https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```
**Features**: Metrics collection, PromQL queries, targets monitoring

### Jaeger Tracing
```
https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```
**Features**: Request tracing, service dependencies, performance analysis

---

## 🚀 Quick Start - 3 Steps

### Step 1: Open Grafana Dashboard
1. Visit: https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
2. Accept SSL certificate (Advanced → Proceed)
3. Login: admin / grafana123
4. Go to Dashboards → "🥜 Dry Fruits Platform - System Overview"

**You'll see:**
- ✅ Service status (UP/DOWN indicators)
- 📊 Request rates in real-time
- ⏱️ Response time graphs
- ❌ Error rate trending

### Step 2: Run Synthetic Monitoring
```powershell
.\synthetic-monitor-enhanced.ps1 -DurationMinutes 10
```

**Output shows:**
```
✅ Customer Portal Homepage [200] 245ms
✅ User Service Root [200] 156ms
✅ Payment Service Health [200] 123ms
✅ Grafana Dashboard [200] 289ms

📈 MONITORING STATISTICS
Total Checks:    45
Successful:      43 (95.6%)
Failed:          2
Success Rate:    95.6% ✅
```

### Step 3: View Traces in Jaeger
1. Visit: https://jaeger-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
2. Select service (e.g., "user-service")
3. Click "Find Traces"
4. View request flows and timing

---

## 📊 What You Can Monitor

### 1. Service Health
**Tool**: Grafana Dashboard  
**Panels**: Service Status, Uptime  
**Alert if**: Any service shows RED

### 2. Performance
**Tool**: Grafana + Prometheus  
**Metrics**: Response time, latency percentiles  
**Alert if**: Response time > 2000ms

### 3. Errors
**Tool**: Grafana Dashboard  
**Panels**: Error rate, error count  
**Alert if**: Error rate > 5%

### 4. Request Flow
**Tool**: Jaeger  
**View**: Complete request path from frontend to database  
**Use for**: Debugging slow requests

### 5. Availability
**Tool**: Synthetic Monitoring Script  
**Tests**: All endpoints every 30 seconds  
**Output**: Success rate, error log

---

## 🤖 Synthetic Monitoring Commands

### Basic Monitoring (60 minutes)
```powershell
.\synthetic-monitor-enhanced.ps1
```

### Continuous Monitoring
```powershell
.\synthetic-monitor-enhanced.ps1 -Continuous -IntervalSeconds 30
```

### Custom Duration
```powershell
.\synthetic-monitor-enhanced.ps1 -DurationMinutes 120 -IntervalSeconds 60
```

---

## 🧪 What Gets Tested

**Frontend:**
- ✅ Customer Portal
- ✅ Admin Dashboard

**Backend Services:**
- ✅ User Service (root, health, actuator, info)
- ✅ Payment Service (root, health, test-cards)

**Authentication:**
- ✅ Registration endpoint
- ✅ Login endpoint

**Complete Journey:**
- ✅ Homepage → Browse → Cart → Checkout → Payment

**Observability:**
- ✅ Grafana dashboard
- ✅ Prometheus metrics API
- ✅ Jaeger UI

---

## 🚨 Error Detection

### Automatic Detection

**1. Grafana Alerts**
- Service down → RED panel
- High error rate → Alert notification
- Slow response → Warning

**2. Prometheus Queries**
```promql
# Check service up
up{job="user-service"} == 0

# High error rate
rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
```

**3. Synthetic Monitor**
- ❌ Failed endpoint checks
- Error log file generated
- Console output with failure details

---

## 📱 Alert Setup (Optional)

### In Grafana:
1. Edit dashboard panel
2. Go to Alert tab
3. Set condition (e.g., service down for 1 minute)
4. Add notification channel (email, Slack, webhook)
5. Save

---

## ✅ Verification Checklist

Run this to verify everything works:

```powershell
# 1. Check pods
oc get pods -n dry-fruits-platform | Select-String "grafana|prometheus|jaeger"

# Expected: All showing "1/1 Running"

# 2. Check routes
oc get routes -n dry-fruits-platform | Select-String "grafana|prometheus|jaeger"

# Expected: 3 routes with hostnames

# 3. Test Grafana
curl -k https://grafana-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com

# Expected: HTML response

# 4. Test Prometheus
curl -k https://prometheus-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/targets

# Expected: JSON with targets

# 5. Run synthetic monitoring
.\synthetic-monitor-enhanced.ps1 -DurationMinutes 2

# Expected: Success rate > 90%
```

---

## 📖 Full Documentation

See **OBSERVABILITY_COMPLETE_GUIDE.md** for:
- Detailed Grafana dashboard guide
- PromQL query examples
- Jaeger tracing walkthrough
- Alert configuration
- Troubleshooting

---

## 🎯 Summary

**You have a complete observability stack!**

✅ **Grafana** - Visual dashboards with pre-built platform overview  
✅ **Prometheus** - Metrics collection and querying  
✅ **Jaeger** - Distributed request tracing  
✅ **Synthetic Monitoring** - Automated endpoint testing  
✅ **Error Detection** - Real-time alerts and logging  

**All accessible via HTTPS routes and ready to use!**

**Quick Start**: Open Grafana dashboard and run `.\synthetic-monitor-enhanced.ps1` 🚀
