#!/bin/bash

# Mankind Matrix AI Backend - Comprehensive Keycloak Setup Script
# This script sets up the database, configures Keycloak, and starts it with MySQL persistence

# Load environment variables from .env
if [ -f "../../.env" ]; then
    echo "🔄 Loading environment variables from .env..."
    set -a
    source ../../.env
    set +a
elif [ -f "../.env" ]; then
    echo "🔄 Loading environment variables from .env..."
    set -a
    source ../.env
    set +a
elif [ -f ".env" ]; then
    echo "🔄 Loading environment variables from .env..."
    set -a
    source .env
    set +a
else
    echo "❌ .env file not found! Please create one with database configuration."
    exit 1
fi

echo "🔐 Setting up Keycloak for Mankind Matrix AI Backend (Comprehensive Setup)..."

# Check if database configuration is available
if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo "❌ Database configuration missing from .env file"
    echo "   Required: DB_HOST, DB_NAME, DB_USERNAME, DB_PASSWORD"
    exit 1
fi

echo "📊 Database Configuration:"
echo "   Host: $DB_HOST"
echo "   Port: ${DB_PORT:-3306}"
echo "   Database: $DB_NAME"
echo "   Username: $DB_USERNAME"

# Test database connection
echo "🔍 Testing database connection..."
if mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    echo "   Please check your database configuration and network connectivity"
    exit 1
fi

# Check if database exists
echo "🔍 Checking if database exists..."
if mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_NAME;" > /dev/null 2>&1; then
    echo "✅ Database '$DB_NAME' exists"
else
    echo "⚠️  Database '$DB_NAME' does not exist, creating..."
    mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
    if [ $? -eq 0 ]; then
        echo "✅ Database '$DB_NAME' created successfully"
    else
        echo "❌ Failed to create database"
        exit 1
    fi
fi

# Check if Keycloak tables exist
echo "🔍 Checking for Keycloak tables..."
TABLE_COUNT=$(mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USERNAME" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SHOW TABLES LIKE 'USER_ENTITY';" 2>/dev/null | wc -l)

if [ "$TABLE_COUNT" -gt 1 ]; then
    echo "✅ Keycloak tables already exist"
else
    echo "ℹ️  Keycloak tables will be created automatically on first startup"
fi

# Set Keycloak DB config from .env
export KC_DB=mysql
export KC_DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT:-3306}/${DB_NAME}?useSSL=${DB_USE_SSL:-false}&allowPublicKeyRetrieval=${DB_ALLOW_PUBLIC_KEY_RETRIEVAL:-true}&serverTimezone=${DB_SERVER_TIMEZONE:-UTC}&autoReconnect=${DB_AUTO_RECONNECT:-true}"
export KC_DB_USERNAME=$DB_USERNAME
export KC_DB_PASSWORD=$DB_PASSWORD

# Set Keycloak admin credentials from .env if available
if [ ! -z "$ADMIN_USERNAME" ]; then
    export KEYCLOAK_ADMIN=$ADMIN_USERNAME
    export KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASSWORD
    echo "👤 Using admin credentials: $ADMIN_USERNAME"
else
    # Fallback to default admin credentials
    export KEYCLOAK_ADMIN=admin
    export KEYCLOAK_ADMIN_PASSWORD=admin
    echo "👤 Using default admin credentials: admin/admin"
fi

# Kill any process using the Keycloak port (default 8180)
KEYCLOAK_PORT=${KEYCLOAK_HTTP_PORT:-8180}
PID=$(lsof -ti tcp:$KEYCLOAK_PORT)
if [ -n "$PID" ]; then
    echo "🔧 Killing process on port $KEYCLOAK_PORT (PID $PID)"
    kill -9 $PID 2>/dev/null
else
    echo "✅ Port $KEYCLOAK_PORT is free"
fi

# Check if Keycloak is already installed
if [ -d "keycloak-26.0.5" ]; then
    echo "✅ Keycloak is already installed in keycloak-26.0.5/"
    echo "   Updating configuration and starting..."
else
    # Download Keycloak
    echo "📥 Downloading Keycloak 26.0.5..."
    curl -L https://github.com/keycloak/keycloak/releases/download/26.0.5/keycloak-26.0.5.tar.gz -o keycloak.tar.gz

    # Extract Keycloak
    echo "📦 Extracting Keycloak..."
    tar -xzf keycloak.tar.gz

    # Clean up download
    rm keycloak.tar.gz
fi

# Create configuration directory
mkdir -p keycloak-26.0.5/conf

# Create configuration file with database settings
echo "⚙️ Creating Keycloak configuration..."
cat > keycloak-26.0.5/conf/keycloak.conf << EOF
# Keycloak Configuration
http-port=${KEYCLOAK_HTTP_PORT:-8180}
http-enabled=true
import-realm=true

# Database Configuration (MySQL)
db=mysql
db-url=jdbc:mysql://${DB_HOST}:${DB_PORT:-3306}/${DB_NAME}?useSSL=${DB_USE_SSL:-false}&allowPublicKeyRetrieval=${DB_ALLOW_PUBLIC_KEY_RETRIEVAL:-true}&serverTimezone=${DB_SERVER_TIMEZONE:-UTC}&autoReconnect=${DB_AUTO_RECONNECT:-true}
db-username=${DB_USERNAME}
db-password=${DB_PASSWORD}

# Admin User Configuration
admin=${ADMIN_USERNAME:-admin}
admin-password=${ADMIN_PASSWORD:-admin}

# Production Settings
hostname=localhost
hostname-port=${KEYCLOAK_HTTP_PORT:-8180}
EOF

# Copy realm configuration
echo "📋 Copying realm configuration..."
mkdir -p keycloak-26.0.5/data/import
cp keycloak/mankind-realm.json keycloak-26.0.5/data/import/

# Start Keycloak in production mode (not development mode)
echo "🚀 Starting Keycloak with database configuration..."
cd keycloak-26.0.5

# Use production mode instead of development mode
./bin/kc.sh start --import-realm

# Wait for Keycloak to be ready
echo "⏳ Waiting for Keycloak to start..."
sleep 20

# Check if Keycloak is ready
echo "🔍 Checking if Keycloak is ready..."
for i in {1..30}; do
    if curl -s http://localhost:8180/health/ready > /dev/null 2>&1; then
        echo "✅ Keycloak is ready!"
        break
    fi
    echo "   Waiting... (attempt $i/30)"
    sleep 3
done

# Verify admin user and realm
echo "🔐 Verifying setup..."
if curl -s http://localhost:8180/admin > /dev/null 2>&1; then
    echo "✅ Keycloak admin console is accessible"
else
    echo "❌ Keycloak admin console not accessible"
fi

echo ""
echo "🎉 Keycloak setup complete!"
echo ""
echo "📋 Access Information:"
echo "   Keycloak Admin:   http://localhost:8180/admin"
echo "   Admin Username:   ${ADMIN_USERNAME:-admin}"
echo "   Admin Password:   ${ADMIN_PASSWORD:-admin}"
echo "   Realm:            mankind (automatically imported)"
echo "   Database:         ${DB_HOST}/${DB_NAME}"
echo "   Persistence:      ✅ MySQL Database (persistent)"
echo ""
echo "💡 You can now run: ./scripts/run-all-services.sh"
echo ""
echo "🔧 Keycloak is now running in production mode with database persistence."
echo "   Admin credentials will be saved in the database and persist across restarts." 