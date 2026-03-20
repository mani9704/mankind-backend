#!/bin/bash

# Setup swap space if not already done
setup_swap() {
    if ! swapon --show | grep -q "/swapfile"; then
        echo "Setting up swap space..."
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
}

# Function to build and start a service
build_and_start_service() {
    local service=$1
    echo "Building and starting $service..."
    
    # Clean Docker before each build
    docker system prune -f
    
    # Build with memory limits
    DOCKER_BUILDKIT=1 docker-compose build \
        --build-arg MAVEN_OPTS="-Xmx512m -XX:MaxMetaspaceSize=256m" \
        $service
    
    # Start with memory limits
    docker-compose up -d \
        --no-deps \
        --scale $service=1 \
        $service
    
    echo "Waiting for $service to stabilize..."
    sleep 45
    
    # Verify service is running
    if ! docker-compose ps $service | grep -q "Up"; then
        echo "Error: $service failed to start properly"
        docker-compose logs $service
        exit 1
    fi
}

# Setup swap first
setup_swap

# Clean up first
echo "Cleaning up Docker system..."
docker-compose down
docker system prune -af

# Show current memory status
echo "Current memory status:"
free -h

# Build and start services one by one
build_and_start_service "product-service"
build_and_start_service "user-service"
build_and_start_service "cart-service"
build_and_start_service "wishlist-service"

# Show final status
echo "All services have been started. Checking status..."
docker-compose ps

# Show memory status after all services are up
echo "Final memory status:"
free -h 