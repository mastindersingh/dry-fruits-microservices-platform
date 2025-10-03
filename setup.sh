#!/bin/bash

echo "============================================"
echo "    Dry Fruits Platform - System Setup"
echo "============================================"
echo ""

echo "[1/5] Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not running!"
    echo "Please install Docker and try again."
    exit 1
fi
echo "Docker is available ✓"

echo ""
echo "[2/5] Starting infrastructure services..."
if ! docker-compose -f docker-compose-light.yml up -d postgres-shared redis rabbitmq; then
    echo "ERROR: Failed to start infrastructure services!"
    exit 1
fi
echo "Infrastructure services started ✓"

echo ""
echo "[3/5] Building all services (this may take several minutes)..."
if ! docker-compose -f docker-compose-light.yml build; then
    echo "ERROR: Failed to build services!"
    exit 1
fi
echo "Services built successfully ✓"

echo ""
echo "[4/5] Starting backend services..."
if ! docker-compose -f docker-compose-light.yml up -d eureka-server inventory-service shipping-service; then
    echo "ERROR: Failed to start backend services!"
    exit 1
fi
echo "Backend services started ✓"

echo ""
echo "[5/5] Starting frontend applications..."
if ! docker-compose -f frontend-only.yml up -d; then
    echo "ERROR: Failed to start frontend applications!"
    exit 1
fi
echo "Frontend applications started ✓"

echo ""
echo "============================================"
echo "           SETUP COMPLETE! "
echo "============================================"
echo ""
echo "Your applications are now available at:"
echo ""
echo "📱 Customer Portal:    http://localhost:3000"
echo "🛠️  Admin Dashboard:    http://localhost:3001"
echo "🔍 Service Discovery:  http://localhost:8761"
echo "📊 RabbitMQ Management: http://localhost:15672"
echo ""
echo "Credentials:"
echo "• Database: dryfruits_user / dryfruits_pass123"
echo "• RabbitMQ: admin / admin123"
echo ""
echo "Services are starting up... Please wait 2-3 minutes"
echo "for all services to be fully available."
echo ""
echo "To check status: docker ps"
echo "To view logs: docker logs [service-name]"
echo ""