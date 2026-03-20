# Mankind Matrix AI AWS Deployment Guide

This guide provides the most cost-effective way to deploy the Mankind Matrix AI microservices on AWS.

## Cost Overview

### Current Setup (Most Cost-Effective)
- Single EC2 t3.small instance: ~$20-25/month
- RDS (already set up): ~$15-20/month
- **Total: ~$35-45/month**

### Comparison with Other Options
1. **ECS with Fargate**: ~$120-160/month
2. **Elastic Beanstalk**: ~$140-180/month
3. **Lambda + API Gateway**: Pay per request (not suitable for constant traffic)

## Deployment Steps

### Step 1: Create AWS Access Keys

1. **Sign in to AWS Console**:
   - Go to [AWS Console](https://aws.amazon.com/console/)
   - Sign in with your AWS account

2. **Create IAM User**:
   - Go to IAM (Identity and Access Management)
   - Click "Users" in the left sidebar
   - Click "Create user"
   - Enter a username (e.g., `mankind-admin`)
   - Click "Next"

3. **Set Permissions**:
   - Select "Attach policies directly
   - Search for and select these policies:
     - `AmazonEC2FullAccess`
     - `AmazonRDSFullAccess`
     - `AmazonSSMFullAccess`
   - Click "Next"
   - Review and click "Create user"

4. **Create Access Keys**:
   - Click on the newly created user
   - Go to "Security credentials" tab
   - Under "Access keys", click "Create access key"
   - Select "Command Line Interface (CLI)"
   - Check the acknowledgment box
   - Click "Next"
   - Click "Create access key"
   - **IMPORTANT**: Download the CSV file or copy both:
     - Access key ID
     - Secret access key
   - Store these securely - you won't be able to see the secret key again

5. **Configure AWS CLI**:
   ```bash
   aws configure
   AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
   AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
   Default region name [None]: us-west-1
   Default output format [None]: json
   ```

### Step 2: Set Up AWS Services

1. **Use the Same VPC as Your RDS Database**:
   - When launching your EC2 instance, always select the **same VPC** that your RDS database is using.
   - Do **not** create a new VPC if your database already exists; using different VPCs will prevent your EC2 and RDS from communicating via security groups.
   - To find your RDS VPC:
     1. Go to the RDS Dashboard
     2. Click your database instance
     3. In the "Connectivity & security" tab, note the **VPC ID**
   - When launching your EC2 instance, select this same VPC in the "Network settings" section.

2. **Create Security Group for EC2**:
   - Go to EC2 Dashboard
   - Click "Security Groups" in the left sidebar
   - Click "Create security group"
   - Configure:
     - Name: `mankind-ec2-sg`
     - Description: "Security group for Mankind Matrix services"
     - VPC: **Select the same VPC as your RDS database**
   - **Find Your IP Address** (needed for SSH access):
     ```bash
     # Method 1: Using curl
     curl ifconfig.me
     
     # Method 2: Using ipconfig (macOS)
     ipconfig getifaddr en0  # For WiFi
     # or
     ipconfig getifaddr en1  # For Ethernet
     
     # Method 3: Visit a website
     # - whatismyip.com
     # - ipinfo.io
     ```
   - Add inbound rules:
     ```
     Type        Port Range    Source
     SSH         22           Your IP/32  # Replace "Your IP" with the IP you found
     HTTP        80           0.0.0.0/0
     HTTPS       443          0.0.0.0/0
     Custom TCP  8080-8083    0.0.0.0/0
     ```
   - Click "Create security group"

3. **Configure Security Group for RDS (Allow EC2 Access)**:
   - If you already have an RDS database and security group, you do **not** need to create a new security group.
   - Instead, update the inbound rules of your existing RDS security group to allow connections from your EC2 instance's security group (created in Step 2).
   - Steps:
     1. Go to the RDS Dashboard
     2. Click "Databases" and select your database instance
     3. In the "Connectivity & security" tab, find the "VPC security groups" section
     4. Click the security group link to open it in the EC2 console
     5. Click "Edit inbound rules"
     6. Add or confirm a rule:
        ```
        Type        Port Range    Source
        MySQL       3306         mankind-ec2-sg (or the security group ID from Step 2)
        ```
     7. Save the rules
   - This allows your EC2 instance to connect to the RDS database securely.
   - **Only create a new security group if you do not already have one for your RDS instance.**

4. **Launch EC2 Instance**:
   - Go to EC2 Dashboard
   - Click "Launch Instance"
   - Configure:
     - Name: `mankind-matrix-server`
     - AMI: Amazon Linux 2023
     - Instance type: t3.small
     - Key pair: Create new
       - Name: `mankind-key`
       - Download the .pem file
     - Network settings:
       - VPC: Select your RDS VPC
       - Subnet: Select a public subnet
       - Security group: Select `mankind-ec2-sg`
     - Storage: 20GB gp3
   - Click "Launch Instance"

5. **Verify Setup**:
   ```bash
   # Test EC2 connection
   ssh -i "mankind-key.pem" ec2-user@your-ec2-ip

   # Test RDS connection (from EC2)
   mysql -h mankind-matrix-db.cd0qkick6gy2.us-west-1.rds.amazonaws.com \
     -u matrix_user -p \
     -e "SELECT 1;"
   ```

### Step 3: Deploy Services

1. **Connect to EC2 Instance**:
   ```bash
   ssh -i "mankind-key.pem" ec2-user@your-ec2-ip
   example: ssh -i "mankind-key.pem" ec2-user@3.101.43.72
   ```

2. **Install Required Software**:
   ```bash
   # Update system
   sudo yum update -y

   # Install Docker
   sudo yum install -y docker

   # Start Docker
   sudo systemctl start docker
   sudo systemctl enable docker

   # Add ec2-user to docker group
   sudo usermod -a -G docker ec2-user

   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose

   # Install Git
   sudo yum install -y git

   # Log out and log back in for group changes to take effect
   exit
   ```

3. **Deploy Services**:
   ```bash
   # Clone repository
   git clone https://github.com/rebeccayilma/mankind-backend.git
   cd mankind-backend

   # Copy .env.example to each service as .env
   for d in user-service product-service cart-service wishlist-service; do cp .env.example $d/.env; done

   # (Optional) Edit each .env file to customize settings for each service
   nano user-service/.env
   nano product-service/.env
   # ...and so on

   # Choose one of the following build methods:

   # Method 1: Standard build (for instances with 2GB+ RAM)
   chmod +x build-services.sh
   ./build-services.sh

   # Method 2: Conservative build (recommended for t3.small or smaller instances)
   chmod +x build-services-conservative.sh
   ./build-services-conservative.sh

   # Note: The conservative build script:
   # - Sets up 4GB of swap space
   # - Builds and starts services one at a time
   # - Includes memory monitoring
   # - Performs health checks
   # - Is recommended for t3.small (2GB RAM) instances

   **Build Scripts Overview**:
   - `build-services.sh`: Standard build script that starts all services at once. Use this only if you have an instance with more than 2GB RAM.
   - `build-services-conservative.sh`: Conservative build script that manages memory usage carefully. Recommended for t3.small instances.
   
   **Which Script to Use?**
   - For t3.small (2GB RAM) or smaller instances: Use `build-services-conservative.sh`
   - For larger instances (4GB+ RAM): You can use either script, but `build-services.sh` might be faster
   
   **Note**: Both scripts are maintained in the repository as they serve different purposes:
   - The conservative script is essential for smaller instances
   - The standard script is useful for development or larger instances
   - Having both allows flexibility in deployment based on your instance size

   **Verifying Services**:
   After deployment, verify that all services are running correctly:

   ```bash
   # Check status of all containers
   docker-compose ps

   # Expected output should show all services as "healthy":
   # NAME                       STATUS                        PORTS
   # mankind-product-service    Up X minutes (healthy)        0.0.0.0:8080->8080/tcp
   # mankind-user-service      Up X minutes (healthy)        0.0.0.0:8081->8080/tcp
   # mankind-cart-service      Up X minutes (healthy)        0.0.0.0:8082->8080/tcp
   # mankind-wishlist-service  Up X minutes (healthy)        0.0.0.0:8083->8080/tcp

   # Check container logs if needed
   docker-compose logs -f [service-name]
   # Example: docker-compose logs -f product-service

   # Check memory usage
   free -h
   docker stats --no-stream

   # Test service health endpoints
   curl http://localhost:8080/actuator/health  # Product Service
   curl http://localhost:8081/actuator/health  # User Service
   curl http://localhost:8082/actuator/health  # Cart Service
   curl http://localhost:8083/actuator/health  # Wishlist Service
   ```

   If any service shows as "unhealthy" or fails to start:
   1. Check the logs: `docker-compose logs -f [service-name]`
   2. Verify environment variables: `docker-compose config`
   3. Check memory usage: `free -h`
   4. Restart the service: `docker-compose restart [service-name]`
   ```

### Step 4: Set Up Nginx (Optional but Recommended)

Nginx serves as a reverse proxy and load balancer for our microservices, providing several important benefits:

1. **Unified Access Point**:
   - Instead of accessing each service on different ports (8080, 8081, 8082, 8083), Nginx provides a single entry point
   - All services can be accessed through a single domain/IP address
   - Example: Instead of `http://your-ip:8080` and `http://your-ip:8081`, you can use `http://your-ip/product-service` and `http://your-ip/user-service`

2. **Security Benefits**:
   - Hides internal service ports from external access
   - Can implement SSL/TLS termination (HTTPS)
   - Provides an additional layer of security
   - Can implement rate limiting and request filtering

3. **Load Balancing**:
   - Can distribute traffic across multiple instances of services
   - Helps handle high traffic loads
   - Provides failover capabilities

4. **Performance**:
   - Caches static content
   - Compresses responses
   - Handles SSL/TLS encryption/decryption
   - Reduces load on application servers

To set up Nginx:

1. **Install Nginx**:
   ```bash
   sudo yum install -y nginx
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

2. **Configure Nginx**:
   ```bash
   sudo nano /etc/nginx/conf.d/mankind.conf
   ```

   Add this configuration:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;  # Replace with your domain or IP

       # Product Service
       location /product-service/ {
           proxy_pass http://localhost:8080/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # User Service
       location /user-service/ {
           proxy_pass http://localhost:8081/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # Cart Service
       location /cart-service/ {
           proxy_pass http://localhost:8082/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # Wishlist Service
       location /wishlist-service/ {
           proxy_pass http://localhost:8083/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # Health check endpoint
       location /health {
           access_log off;
           return 200 'healthy\n';
       }
   }
   ```

3. **Test and Restart Nginx**:
   ```bash
   # Test configuration
   sudo nginx -t

   # If test is successful, restart Nginx
   sudo systemctl restart nginx
   ```

4. **Verify Setup**:
   After configuration, your services will be available at:
   - Product Service: `http://your-domain.com/product-service`
   - User Service: `http://your-domain.com/user-service`
   - Cart Service: `http://your-domain.com/cart-service`
   - Wishlist Service: `http://your-domain.com/wishlist-service`

   Test the endpoints:
   ```bash
   curl http://localhost/product-service/actuator/health
   curl http://localhost/user-service/actuator/health
   curl http://localhost/cart-service/actuator/health
   curl http://localhost/wishlist-service/actuator/health
   ```

**Note**: While Nginx is optional, it's highly recommended for production deployments because it:
- Simplifies service access
- Improves security
- Enables future scaling
- Provides better control over traffic
- Makes it easier to add SSL/TLS later

## Accessing Services

After deployment, your services will be available at:
- Product Service: `http://your-ec2-ip:8080` or `http://your-domain/product-service`
- User Service: `http://your-ec2-ip:8081` or `http://your-domain/user-service`
- Cart Service: `http://your-ec2-ip:8082` or `http://your-domain/cart-service`
- Wishlist Service: `http://your-ec2-ip:8083` or `http://your-domain/wishlist-service`

## Monitoring and Maintenance

1. **View Service Logs**:
   ```bash
   # View all service logs
   docker-compose logs -f

   # View specific service logs
   docker-compose logs -f product-service
   ```

2. **Restart Services**:
   ```bash
   # Restart all services
   docker-compose restart

   # Restart specific service
   docker-compose restart product-service
   ```

3. **Update Services**:
   ```bash
   # Pull latest changes
   git pull

   # Rebuild and restart services
   docker-compose up -d --build
   ```

## Backup and Recovery

1. **Backup Database**:
   ```bash
   # Create backup script
   cat > backup.sh << 'EOL'
   #!/bin/bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   BACKUP_DIR="/home/ec2-user/backups"
   mkdir -p $BACKUP_DIR
   
   # Backup database
   mysqldump -h mankind-matrix-db.cd0qkick6gy2.us-west-1.rds.amazonaws.com \
     -u matrix_user -p matrix_pass mankind_matrix_db > \
     $BACKUP_DIR/db_backup_$TIMESTAMP.sql
   
   # Keep only last 7 backups
   ls -t $BACKUP_DIR/db_backup_* | tail -n +8 | xargs rm -f
   EOL

   chmod +x backup.sh
   ```

2. **Schedule Backups**:
   ```bash
   # Add to crontab
   (crontab -l 2>/dev/null; echo "0 0 * * * /home/ec2-user/backup.sh") | crontab -
   ```

## Cost Optimization Tips

1. **Use Spot Instances**:
   - Can reduce costs by up to 70%
   - Good for development/testing
   - Not recommended for production

2. **Reserved Instances**:
   - Commit to 1 or 3 years
   - Can save up to 40% on costs
   - Good for production workloads

3. **Monitor Usage**:
   - Use AWS CloudWatch
   - Set up billing alerts
   - Review unused resources

## Cleanup

To stop and remove all resources:
```bash
# Stop and remove containers
docker-compose down

# Remove images
docker rmi $(docker images -q)

# Terminate EC2 instance through AWS Console
```

## Troubleshooting

1. **Service Not Starting**:
   - Check Docker logs: `docker-compose logs`
   - Verify environment variables
   - Check database connectivity

2. **Database Connection Issues**:
   - Verify RDS security group
   - Check database credentials
   - Test connection: `mysql -h mankind-matrix-db.cd0qkick6gy2.us-west-1.rds.amazonaws.com -u matrix_user -p`

3. **High Resource Usage**:
   - Monitor with `top` or `htop`
   - Check Docker stats: `docker stats`
   - Review application logs

## Security Best Practices

1. **Access Keys**:
   - Never commit access keys to git
   - Rotate keys periodically
   - Use IAM roles when possible
   - Follow principle of least privilege

2. **Security Groups**:
   - Keep security groups as restrictive as possible
   - Regularly review and update rules
   - Remove unused rules

3. **RDS Security**:
   - Use private subnets for RDS
   - Enable encryption at rest
   - Regular backups
   - Strong passwords

4. **EC2 Security**:
   - Regular system updates
   - Use security groups
   - Monitor instance metrics
   - Enable CloudWatch alarms

For more detailed information about any of these steps, refer to the [AWS Documentation](https://docs.aws.amazon.com/). 