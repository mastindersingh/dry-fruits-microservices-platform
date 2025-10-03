#!/bin/bash

echo "============================================"
echo "  Dry Fruits Platform - Enhanced Setup"
echo "  with Full Observability Stack"
echo "============================================"
echo ""

echo "[1/7] Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not running!"
    echo "Please install Docker and try again."
    exit 1
fi
echo "Docker is available ✓"

echo ""
echo "[2/7] Starting infrastructure services..."
if ! docker-compose -f docker-compose-light.yml up -d postgres-shared redis rabbitmq; then
    echo "ERROR: Failed to start infrastructure services!"
    exit 1
fi
echo "Infrastructure services started ✓"

echo ""
echo "[3/7] Starting observability stack (Prometheus, Grafana, Jaeger)..."
if ! docker-compose -f docker-compose-observability.yml up -d; then
    echo "ERROR: Failed to start observability stack!"
    exit 1
fi
echo "Observability stack started ✓"

echo ""
echo "[4/7] Building all services (this may take several minutes)..."
if ! docker-compose -f docker-compose-light.yml build; then
    echo "ERROR: Failed to build services!"
    exit 1
fi
echo "Services built successfully ✓"

echo ""
echo "[5/7] Starting backend services..."
if ! docker-compose -f docker-compose-light.yml up -d eureka-server inventory-service shipping-service; then
    echo "ERROR: Failed to start backend services!"
    exit 1
fi
echo "Backend services started ✓"

echo ""
echo "[6/7] Starting frontend applications..."
if ! docker-compose -f frontend-only.yml up -d; then
    echo "ERROR: Failed to start frontend applications!"
    exit 1
fi
echo "Frontend applications started ✓"

echo ""
echo "[7/7] Waiting for services to become healthy..."
sleep 30
echo "Services initialization complete ✓"

echo ""
echo "============================================"
echo "       ENHANCED SETUP COMPLETE! "
echo "============================================"
echo ""
echo "🚀 APPLICATION ACCESS:"
echo "📱 Customer Portal:      http://localhost:3000"
echo "🛠️  Admin Dashboard:      http://localhost:3001"
echo "🔍 Service Discovery:    http://localhost:8761"
echo ""
echo "📊 OBSERVABILITY DASHBOARD:"
echo "📈 Grafana Dashboard:    http://localhost:3300 (admin/grafana123)"
echo "🔥 Prometheus Metrics:   http://localhost:9090"
echo "🕵️  Jaeger Tracing:       http://localhost:16686"
echo "🚨 AlertManager:         http://localhost:9093"
echo "📋 Log Aggregation:      http://localhost:3100"
echo ""
echo "🔧 INFRASTRUCTURE ACCESS:"
echo "🐰 RabbitMQ Management:  http://localhost:15672 (admin/admin123)"
echo "💾 Database:             localhost:5432 (dryfruits_user/dryfruits_pass123)"
echo "🗄️  Redis Cache:          localhost:6379"
echo ""
echo "📡 TELEMETRY ENDPOINTS:"
echo "🔭 OTLP Collector:       http://localhost:4317 (gRPC), http://localhost:4318 (HTTP)"
echo "📊 Node Exporter:        http://localhost:9100"
echo "🐳 cAdvisor:             http://localhost:8080"
echo ""
echo "⚡ EXTERNAL INTEGRATIONS:"
echo "Edit .env.observability to configure:"
echo "• Datadog, Splunk, Elastic APM, New Relic"
echo "• Slack/Email alerts, PagerDuty"
echo ""
echo "Services are starting up... Please wait 2-3 minutes"
echo "for all observability features to be fully available."
echo ""
echo "To check status: docker ps"
echo "To view logs: docker logs [service-name]"
echo "For full documentation: see SYSTEM_DOCUMENTATION.md"
echo ""