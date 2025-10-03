#!/bin/bash
# Synthetic Monitoring Script for Dry Fruits Platform

echo "🚀 Starting Synthetic Monitoring for Dry Fruits Platform..."

# Base URLs
CUSTOMER_PORTAL="http://localhost:30900"
ADMIN_DASHBOARD="http://localhost:8080"
INVENTORY_API="http://localhost:8084"
SHIPPING_API="http://localhost:8085"
EUREKA_SERVER="http://localhost:8762"

# Synthetic user data
USERS=("john_doe" "jane_smith" "mike_wilson" "sarah_johnson" "david_brown")
PRODUCTS=("almonds" "cashews" "walnuts" "pistachios" "dried_dates")

# Function to generate random load
generate_load() {
    local endpoint=$1
    local description=$2
    
    echo "📊 Testing $description..."
    
    for i in {1..10}; do
        # Simulate user requests with delays
        curl -s -w "Status: %{http_code}, Time: %{time_total}s\n" \
             -H "User-Agent: SyntheticMonitor/1.0" \
             -H "X-Request-ID: synthetic-$(date +%s)-$i" \
             "$endpoint" > /dev/null &
        
        # Random delay between requests (0.1 to 2 seconds)
        sleep $(echo "scale=1; $(shuf -i 1-20 -n 1)/10" | bc)
    done
    
    wait
}

# Function to simulate business workflows
simulate_user_journey() {
    local user=$1
    echo "👤 Simulating user journey for: $user"
    
    # 1. Visit customer portal homepage
    curl -s "$CUSTOMER_PORTAL" \
         -H "User-Agent: SyntheticUser-$user" \
         -H "X-User-Session: session-$user-$(date +%s)" > /dev/null
    
    # 2. Check service health
    curl -s "$INVENTORY_API/actuator/health" \
         -H "X-User-Session: session-$user-$(date +%s)" > /dev/null
    
    # 3. Browse products (simulate API calls)
    for product in ${PRODUCTS[@]}; do
        curl -s "$INVENTORY_API/api/inventory/search?product=$product" \
             -H "X-User-Session: session-$user-$(date +%s)" > /dev/null || true
        sleep 0.5
    done
    
    # 4. Check shipping options
    curl -s "$SHIPPING_API/actuator/health" \
         -H "X-User-Session: session-$user-$(date +%s)" > /dev/null
    
    # 5. Admin operations (simulate admin user)
    if [[ "$user" == "admin_user" ]]; then
        curl -s "$ADMIN_DASHBOARD" \
             -H "X-Admin-Session: admin-session-$(date +%s)" > /dev/null
    fi
    
    echo "✅ User journey completed for: $user"
}

# Main monitoring loop
echo "🎯 Starting continuous synthetic monitoring..."

# Generate initial load burst
echo "📈 Generating initial load burst..."
generate_load "$CUSTOMER_PORTAL" "Customer Portal"
generate_load "$ADMIN_DASHBOARD" "Admin Dashboard"
generate_load "$INVENTORY_API/actuator/health" "Inventory Service Health"
generate_load "$SHIPPING_API/actuator/health" "Shipping Service Health"
generate_load "$EUREKA_SERVER/eureka/apps" "Eureka Service Registry"

# Simulate user journeys
echo "🚶 Simulating user journeys..."
for user in ${USERS[@]}; do
    simulate_user_journey "$user" &
done

# Add admin user journey
simulate_user_journey "admin_user" &

# Wait for all background processes
wait

echo "✅ Synthetic monitoring cycle completed!"
echo "📊 Check Grafana dashboard: http://localhost:3000"
echo "🔍 View traces in Jaeger: http://localhost:16686"
echo "📈 Monitor metrics in Prometheus: http://localhost:9091"