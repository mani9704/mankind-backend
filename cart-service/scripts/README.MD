# Database Setup for Cart Service

This guide provides instructions for setting up and configuring the database connection for the Cart Service.

## Overview
These steps ensure successful database connectivity for the Cart Service application.

## Setup Steps

### 1. Database Host Configuration
- Set up a database host (local or remote)
- For local databases, verify MySQL service status:
  ```bash
  # macOS
  brew services list | grep mysql
  
  # Linux
  systemctl status mysql
  
  # Windows
  sc query mysql
  ```

### 2. Database Connection Testing
1. Ensure MySQL is running and update the `.env` file with your database connection details
2. Run the connection test:
   ```bash
   ./mvnw test -Dtest=ConnectionTest
   ```
3. Optional: Install MySQL Workbench
   - Download from [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
   - Use it to connect and manage your database

### 3. Database Schema Creation
Run the following command to create the database schema:
```bash
mysql -h <HOST> -u <USER> -p'<PASSWORD>' < scripts/setup.sql
```

Example for local environment:
```bash
mysql -h localhost -u root -p'password' < scripts/setup.sql
```

### 4. Table Creation
The application uses automatic table mapping through JPA, which generates or updates tables during runtime.

To start the application:
```bash
./mvnw spring-boot:run
```

To verify created tables:
```bash
mysql -h <HOST> -u <USER> -p'<PASSWORD>' -e "USE mankind_matrix_db; SHOW TABLES;"
```

Example for local environment:
```bash
mysql -h localhost -u root -p'password' -e "USE mankind_matrix_db; SHOW TABLES;"
```

### 5. Sample Data Insertion
To populate the database with sample cart items:
```bash
mysql -h <HOST> -u <USER> -p'<PASSWORD>' < scripts/sample_cart_insert.sql
```

Example for local environment:
```bash
mysql -h localhost -u root -p'password' < scripts/sample_cart_insert.sql
```

## Troubleshooting

### Common Issues
1. **Connection refused**: Ensure MySQL is running and accessible
2. **Access denied**: Verify username and password in the `.env` file
3. **Table not found**: Make sure the application has started at least once to create tables

### Logging
Check application logs for database-related errors:
```bash
tail -f logs/application.log
```