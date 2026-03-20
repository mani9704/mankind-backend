#!/bin/bash

# Setup swap space if not already done
setup_swap() {
    if ! swapon --show | grep -q "/swapfile"; then
        echo "Setting up swap space..."
        sudo fallocate -l 4G /swapfile  # Increased to 4GB
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
}

# Function to clean Docker
clean_docker() {
    echo "Cleaning Docker system..."
    docker-compose down
    docker system prune -af
    docker builder prune -af
    docker volume prune -f
}

# Function to build and start a service
build_and_start_service() {
    local service=$1
    echo "Building and starting $service..."
    
    # Clean Docker before each build
    clean_docker
    
    # Show memory status before build
    echo "Memory status before building $service:"
    free -h
    
    # Build with very conservative memory limits
    DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build \
        --build-arg MAVEN_OPTS="-Xmx256m -XX:MaxMetaspaceSize=128m" \
        --no-cache \
        $service
    
    # Start with conservative memory limits
    docker-compose up -d \
        --no-deps \
        --scale $service=1 \
        $service
    
    echo "Waiting for $service to stabilize..."
    sleep 60  # Increased wait time
    
    # Verify service is running
    if ! docker-compose ps $service | grep -q "Up"; then
        echo "Error: $service failed to start properly"
        docker-compose logs $service
        exit 1
    fi
    
    # Show memory status after service is up
    echo "Memory status after $service is up:"
    free -h
    
    # Wait for service to be healthy
    echo "Waiting for $service to be healthy..."
    for i in {1..12}; do
        if docker-compose ps $service | grep -q "healthy"; then
            echo "$service is healthy"
            break
        fi
        if [ $i -eq 12 ]; then
            echo "Warning: $service did not become healthy within timeout"
        fi
        sleep 10
    done
}

# Setup swap first
setup_swap

# Show initial memory status
echo "Initial memory status:"
free -h

# Clean up first
clean_docker

# Build and start services one by one with delays between them
build_and_start_service "product-service"
sleep 30

build_and_start_service "user-service"
sleep 30

build_and_start_service "cart-service"
sleep 30

build_and_start_service "wishlist-service"

# Show final status
echo "All services have been started. Checking status..."
docker-compose ps

# Show final memory status
echo "Final memory status:"
free -h

# Show Docker disk usage
echo "Docker disk usage:"
docker system df 