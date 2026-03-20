#!/bin/bash

# Database Connection Monitoring Script
# This script helps monitor database connections and connection pool usage

echo "🔍 Database Connection Monitor"
echo "=============================="

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

# Function to check if service is running
check_service() {
    local port=$1
    local service_name=$2
    
    if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $service_name (Port $port)${NC}"
        return 0
    else
        echo -e "${RED}❌ $service_name (Port $port)${NC}"
        return 1
    fi
}

# Function to get connection pool status
get_connection_pool_status() {
    local port=$1
    local service_name=$2
    
    if check_service $port $service_name; then
        echo -e "\n${BLUE}📊 $service_name Connection Pool Status:${NC}"
        
        # Try different actuator endpoints for connection pool info
        # Spring Boot 3.x uses different endpoints
        POOL_INFO=$(curl -s "http://localhost:$port/actuator/health" | jq -r '.components.db.details.pool' 2>/dev/null)
        
        if [ "$POOL_INFO" != "null" ] && [ -n "$POOL_INFO" ]; then
            echo "$POOL_INFO" | jq '.'
        else
            # Fallback: check if datasource health is available
            DATASOURCE_HEALTH=$(curl -s "http://localhost:$port/actuator/health/datasource" 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$DATASOURCE_HEALTH" | jq '.'
            else
                echo "   ✅ Service running (connection pool info not available in this Spring Boot version)"
                echo "   💡 Check service logs for connection pool details"
            fi
        fi
    fi
}

# Function to check database connections via MySQL
check_db_connections() {
    echo -e "\n${BLUE}🗄️  Database Connection Status:${NC}"
    
    # Get current connections
    CONNECTIONS=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | tail -1 | awk '{print $2}')
    
    if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" != "Threads_connected" ]; then
        echo "   Current Connections: $CONNECTIONS"
        
        if [ "$CONNECTIONS" -gt 50 ]; then
            echo -e "   ${RED}⚠️  High connection count!${NC}"
        elif [ "$CONNECTIONS" -gt 30 ]; then
            echo -e "   ${YELLOW}⚠️  Moderate connection count${NC}"
        else
            echo -e "   ${GREEN}✅ Connection count looks good${NC}"
        fi
    else
        echo -e "   ${RED}❌ Unable to get connection count${NC}"
    fi
    
    # Get max connections
    MAX_CONNECTIONS=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | tail -1 | awk '{print $2}')
    if [ -n "$MAX_CONNECTIONS" ] && [ "$MAX_CONNECTIONS" != "max_connections" ]; then
        echo "   Max Connections: $MAX_CONNECTIONS"
        
        if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" != "Threads_connected" ]; then
            USAGE_PERCENT=$((CONNECTIONS * 100 / MAX_CONNECTIONS))
            echo "   Usage: $USAGE_PERCENT%"
        fi
    fi
}

# Function to show active processes
show_active_processes() {
    echo -e "\n${BLUE}🔍 Active Database Processes:${NC}"
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "
    SELECT 
        ID as 'Process ID',
        USER as 'User',
        HOST as 'Host',
        DB as 'Database',
        COMMAND as 'Command',
        TIME as 'Time (s)',
        STATE as 'State',
        INFO as 'Query'
    FROM INFORMATION_SCHEMA.PROCESSLIST 
    WHERE COMMAND != 'Sleep' 
    ORDER BY TIME DESC 
    LIMIT 10;" 2>/dev/null || echo "   Unable to get process list"
}

# Main monitoring
echo -e "\n${BLUE}🏥 Service Health Check:${NC}"
check_service 8085 "Gateway Service"
check_service 8180 "Keycloak"
check_service 8081 "User Service"
check_service 8080 "Product Service"
check_service 8082 "Cart Service"
check_service 8083 "Wishlist Service"
check_service 8084 "Payment Service"
check_service 8086 "Notification Service"

# Check database connections
check_db_connections

# Show active processes if requested
if [ "$1" = "--processes" ]; then
    show_active_processes
fi

# Get connection pool status for each service
echo -e "\n${BLUE}📈 Connection Pool Details:${NC}"
get_connection_pool_status 8081 "User Service"
get_connection_pool_status 8080 "Product Service"
get_connection_pool_status 8082 "Cart Service"
get_connection_pool_status 8083 "Wishlist Service"
get_connection_pool_status 8084 "Payment Service"
get_connection_pool_status 8086 "Notification Service"

echo -e "\n${BLUE}💡 Tips:${NC}"
echo "   • Run with --processes to see active database queries"
echo "   • Check AWS RDS Console for detailed metrics"
echo "   • Monitor connection pool usage in service logs"
echo "   • Spring Boot 3.4.4: Connection pool details via service logs"
echo "   • Consider connection pooling proxy for high traffic"

echo -e "\n${GREEN}✅ Monitoring complete${NC}" 