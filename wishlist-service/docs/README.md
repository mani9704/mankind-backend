# Wishlist Service Documentation

## Overview
The Wishlist Service is a microservice component of the Mankind Matrix backend system. It provides functionality for users to create and manage wishlists of products they are interested in. This service allows users to add products to their wishlist, remove products, view their wishlist, and check if a specific product is already in their wishlist.

## Table of Contents
1. [Service Architecture](#service-architecture)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Configuration](#configuration)
5. [Setup and Deployment](#setup-and-deployment)
6. [Error Handling](#error-handling)
7. [Example Requests and Responses](#example-requests-and-responses)

## Service Architecture
The Wishlist Service follows a standard Spring Boot microservice architecture with the following components:

- **Controller Layer**: Handles HTTP requests and responses
- **Service Layer**: Contains business logic
- **Repository Layer**: Manages data access
- **Model Layer**: Defines data structures
- **Exception Handling**: Manages errors and exceptions

### Technology Stack
- Java 17
- Spring Boot 3.2.5
- Spring Data JPA
- MySQL Database
- Swagger/OpenAPI for API documentation
- Maven for dependency management and building

## API Endpoints
The Wishlist Service exposes the following REST API endpoints:

### Add Item to Wishlist
- **Endpoint**: `POST /api/wishlist`
- **Parameters**:
  - `userId` (Long): ID of the user
  - `productId` (Long): ID of the product to add
- **Description**: Adds a product to a user's wishlist
- **Responses**:
  - 200 OK: Item added successfully
  - 400 Bad Request: Item already in wishlist

### Get User's Wishlist
- **Endpoint**: `GET /api/wishlist/{userId}`
- **Parameters**:
  - `userId` (Long): ID of the user
- **Description**: Returns all items in a user's wishlist
- **Responses**:
  - 200 OK: Wishlist retrieved successfully
  - 404 Not Found: User not found or wishlist is empty

### Remove Item from Wishlist
- **Endpoint**: `DELETE /api/wishlist`
- **Parameters**:
  - `userId` (Long): ID of the user
  - `productId` (Long): ID of the product to remove
- **Description**: Removes a product from a user's wishlist
- **Responses**:
  - 200 OK: Item removed successfully
  - 400 Bad Request: Item not found in wishlist

### Check if Item is in Wishlist
- **Endpoint**: `GET /api/wishlist/check`
- **Parameters**:
  - `userId` (Long): ID of the user
  - `productId` (Long): ID of the product to check
- **Description**: Checks if a product is in a user's wishlist
- **Responses**:
  - 200 OK: Check completed successfully (returns boolean)

## Data Models

### WishlistItem
The main entity representing an item in a user's wishlist.

| Field     | Type | Description                                   |
|-----------|------|-----------------------------------------------|
| id        | Long | Primary key (auto-generated, not in JSON)     |
| userId    | Long | ID of the user who owns this wishlist item    |
| productId | Long | ID of the product that is in the wishlist     |

**Database Table**: `wishlist`

**Constraints**: Unique constraint on the combination of `userId` and `productId` to prevent duplicate entries.

## Configuration
The service can be configured through the `application.yml` file:

### Application Configuration
```yaml
spring:
  application:
    name: matrix-wishlist-service
```

### Database Configuration
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wishlistdb?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: 1436
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
```

### Server Configuration
```yaml
server:
  port: 8082
```

### Swagger/OpenAPI Configuration
```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
    enabled: true
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
    tagsSorter: alpha
    tryItOutEnabled: true
  packages-to-scan: com.example.demo.controller
  paths-to-match: /api/**
```

## Setup and Deployment

### Prerequisites
- Java 17 or higher
- MySQL 8.0 or higher
- Maven 3.6 or higher

### Database Setup
1. Create a MySQL database named `wishlistdb`
2. Configure the database connection in `application.yml`

### Building the Service
```bash
mvn clean package
```

### Running the Service
```bash
java -jar target/wishlist-service-0.0.1-SNAPSHOT.jar
```

### Docker Deployment (Optional)
A Dockerfile could be created with the following content:

```dockerfile
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/wishlist-service-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

Build and run the Docker container:
```bash
docker build -t wishlist-service .
docker run -p 8082:8082 wishlist-service
```

## Error Handling
The service uses a global exception handler to manage errors:

| Exception                      | HTTP Status | Description                                   |
|--------------------------------|-------------|-----------------------------------------------|
| UserNotFoundException          | 404         | User not found or has no wishlist items       |
| ProductNotFoundException       | 404         | Product not found                             |
| DuplicateWishlistItemException | 409         | Item already exists in the wishlist           |
| RuntimeException               | 400         | General errors (e.g., item not in wishlist)   |

## Example Requests and Responses

### Add Item to Wishlist
**Request:**
```http
POST http://localhost:8082/api/wishlist?userId=1&productId=100
Accept: application/json
```

**Response (200 OK):**
```json
{
  "userId": 1,
  "productId": 100
}
```

### Get User's Wishlist
**Request:**
```http
GET http://localhost:8082/api/wishlist/1
Accept: application/json
```

**Response (200 OK):**
```json
[
  {
    "userId": 1,
    "productId": 100
  },
  {
    "userId": 1,
    "productId": 101
  }
]
```

### Remove Item from Wishlist
**Request:**
```http
DELETE http://localhost:8082/api/wishlist?userId=1&productId=100
Accept: application/json
```

**Response (200 OK):**
```
No content
```

### Check if Item is in Wishlist
**Request:**
```http
GET http://localhost:8082/api/wishlist/check?userId=1&productId=100
Accept: application/json
```

**Response (200 OK):**
```
true
```