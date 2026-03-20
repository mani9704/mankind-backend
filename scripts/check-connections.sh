#!/bin/bash

echo "🔍 Checking Database Connections"
echo "================================"

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env file not found"
    exit 1
fi

echo "📊 Current Connection Status:"
echo ""

# Check current connections
echo "🔗 Current Database Connections:"
CONNECTIONS=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | tail -1 | awk '{print $2}')

if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" != "Threads_connected" ]; then
    echo "   Active Connections: $CONNECTIONS"
    
    if [ "$CONNECTIONS" -gt 50 ]; then
        echo "   ⚠️  HIGH - You're approaching the 60 connection limit!"
    elif [ "$CONNECTIONS" -gt 30 ]; then
        echo "   ⚠️  MODERATE - Connection count is getting high"
    else
        echo "   ✅ GOOD - Connection count is healthy"
    fi
else
    echo "   ❌ Unable to get connection count"
fi

echo ""

# Check max connections
echo "📈 Connection Limits:"
MAX_CONNECTIONS=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | tail -1 | awk '{print $2}')

if [ -n "$MAX_CONNECTIONS" ] && [ "$MAX_CONNECTIONS" != "max_connections" ]; then
    echo "   Max Connections: $MAX_CONNECTIONS"
    
    if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" != "Threads_connected" ]; then
        USAGE_PERCENT=$((CONNECTIONS * 100 / MAX_CONNECTIONS))
        echo "   Usage: $USAGE_PERCENT%"
        
        if [ "$USAGE_PERCENT" -gt 80 ]; then
            echo "   ⚠️  WARNING: High usage!"
        elif [ "$USAGE_PERCENT" -gt 60 ]; then
            echo "   ⚠️  CAUTION: Moderate usage"
        else
            echo "   ✅ SAFE: Low usage"
        fi
    fi
fi

echo ""
echo "💡 Your Current Settings:"
echo "   DB_HIKARI_MAX_POOL_SIZE: ${DB_HIKARI_MAX_POOL_SIZE:-10}"
echo "   DB_HIKARI_MIN_IDLE: ${DB_HIKARI_MIN_IDLE:-5}"
echo ""
echo "📋 Expected Connections:"
echo "   6 Microservices × ${DB_HIKARI_MAX_POOL_SIZE:-10} = $((6 * ${DB_HIKARI_MAX_POOL_SIZE:-10}))"
echo "   Keycloak: 3 connections"
echo "   Total Expected: $((6 * ${DB_HIKARI_MAX_POOL_SIZE:-10} + 3))"
