#!/bin/bash

# Connection Pool Details Checker
# This script checks connection pool details from service logs

echo "🔍 Connection Pool Details Checker"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

# Function to check service logs for connection pool info
check_service_logs() {
    local service_name=$1
    local port=$2
    local container_name=$3
    
    echo -e "\n${BLUE}📊 $service_name Connection Pool Info:${NC}"
    
    # First check if service is running via HTTP
    if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
        echo "   ✅ Service is running on port $port"
        
        # Try to get connection pool info from actuator health
        HEALTH_INFO=$(curl -s "http://localhost:$port/actuator/health" | jq -r '.components.db.details' 2>/dev/null)
        
        if [ "$HEALTH_INFO" != "null" ] && [ -n "$HEALTH_INFO" ]; then
            echo "   📊 Database Health Info:"
            echo "$HEALTH_INFO" | jq -r 'to_entries[] | "   • \(.key): \(.value)"' 2>/dev/null || echo "   • Status: Available"
        else
            echo "   📊 Database: Connected (details not available via actuator)"
        fi
        
        # If Docker is available, also check container logs
        if command -v docker >/dev/null 2>&1 && docker ps --format "table {{.Names}}" | grep -q "$container_name" 2>/dev/null; then
            echo "   🐳 Checking Docker logs..."
            LOGS=$(docker logs --tail 20 "$container_name" 2>/dev/null | grep -i "hikari\|connection\|pool" | tail -3)
            
            if [ -n "$LOGS" ]; then
                echo "   📝 Recent Connection Pool Logs:"
                echo "$LOGS" | while IFS= read -r line; do
                    echo "     $line"
                done
            else
                echo "   📝 No recent connection pool logs in Docker"
            fi
        fi
        
    else
        echo -e "   ${RED}❌ Service not responding on port $port${NC}"
        
        # Fallback: check if Docker container exists
        if command -v docker >/dev/null 2>&1 && docker ps --format "table {{.Names}}" | grep -q "$container_name" 2>/dev/null; then
            echo "   🐳 Container is running, but service not responding"
        fi
    fi
}

# Function to show current connection pool configuration
show_pool_config() {
    echo -e "\n${BLUE}⚙️  Current Connection Pool Configuration:${NC}"
    echo "   Environment Variables:"
    echo "   • DB_HIKARI_MAX_POOL_SIZE: ${DB_HIKARI_MAX_POOL_SIZE:-2}"
    echo "   • DB_HIKARI_MIN_IDLE: ${DB_HIKARI_MIN_IDLE:-0}"
    echo "   • DB_HIKARI_CONNECTION_TIMEOUT: ${DB_HIKARI_CONNECTION_TIMEOUT:-20000}ms"
    echo "   • DB_HIKARI_IDLE_TIMEOUT: ${DB_HIKARI_IDLE_TIMEOUT:-120000}ms"
    echo "   • DB_HIKARI_MAX_LIFETIME: ${DB_HIKARI_MAX_LIFETIME:-300000}ms"
    echo "   • DB_HIKARI_LEAK_DETECTION_THRESHOLD: ${DB_HIKARI_LEAK_DETECTION_THRESHOLD:-30000}ms"
}

# Function to estimate total connections
estimate_connections() {
    echo -e "\n${BLUE}📈 Estimated Total Connections:${NC}"
    
    local max_pool_size=${DB_HIKARI_MAX_POOL_SIZE:-2}
    local services=7  # user, product, cart, wishlist, payment, notification, gateway
    local keycloak_connections=3  # estimated for Keycloak
    
    local total_estimated=$((services * max_pool_size + keycloak_connections))
    
    echo "   Services: $services"
    echo "   Max Pool Size per Service: $max_pool_size"
    echo "   Keycloak Connections: ~$keycloak_connections"
    echo "   Total Estimated: ~$total_estimated connections"
    
    if [ $total_estimated -gt 50 ]; then
        echo -e "   ${RED}⚠️  High estimated connection count!${NC}"
    elif [ $total_estimated -gt 30 ]; then
        echo -e "   ${YELLOW}⚠️  Moderate estimated connection count${NC}"
    else
        echo -e "   ${GREEN}✅ Estimated connection count looks good${NC}"
    fi
}

# Main execution
show_pool_config
estimate_connections

# Check logs for each service
check_service_logs "User Service" 8081 "mankind-backend-user-service-1"
check_service_logs "Product Service" 8080 "mankind-backend-product-service-1"
check_service_logs "Cart Service" 8082 "mankind-backend-cart-service-1"
check_service_logs "Wishlist Service" 8083 "mankind-backend-wishlist-service-1"
check_service_logs "Payment Service" 8084 "mankind-backend-payment-service-1"
check_service_logs "Notification Service" 8086 "mankind-backend-notification-service-1"
check_service_logs "Gateway Service" 8085 "mankind-backend-mankind-gateway-service-1"

echo -e "\n${BLUE}💡 Tips:${NC}"
echo "   • Connection pool details are logged during service startup"
echo "   • Restart services to see fresh connection pool initialization logs"
echo "   • Monitor AWS RDS for actual connection usage"
echo "   • Works with both direct services and Docker containers"
echo "   • Use 'docker logs -f <container>' for Docker real-time monitoring"

echo -e "\n${GREEN}✅ Connection pool check complete${NC}" 