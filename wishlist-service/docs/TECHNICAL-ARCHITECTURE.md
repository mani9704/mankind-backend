# Wishlist Service Technical Architecture

This document provides a detailed overview of the technical architecture of the Wishlist Service, including its components, interactions, and design patterns.

## Architecture Overview

The Wishlist Service follows a layered architecture pattern common in Spring Boot applications:

```
┌─────────────────────────────────────┐
│            API Layer                │
│        (REST Controllers)           │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│          Service Layer              │
│        (Business Logic)             │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│        Repository Layer             │
│         (Data Access)               │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│          Database                   │
│           (MySQL)                   │
└─────────────────────────────────────┘
```

## Component Details

### 1. API Layer (Controllers)

The API layer is responsible for handling HTTP requests and responses. It defines the REST endpoints and maps them to service methods.

**Key Components:**
- `WishlistController`: Handles all wishlist-related HTTP requests

**Design Patterns:**
- REST API design pattern
- Dependency Injection (via constructor injection)

**Responsibilities:**
- Request validation
- HTTP method mapping
- Response formatting
- Swagger/OpenAPI documentation

### 2. Service Layer

The service layer contains the business logic of the application. It orchestrates the operations between the API layer and the repository layer.

**Key Components:**
- `WishlistService`: Implements the business logic for wishlist operations

**Design Patterns:**
- Facade pattern (simplifies the interface to the repository)
- Dependency Injection

**Responsibilities:**
- Business rule validation
- Transaction management
- Error handling
- Coordinating data access operations

### 3. Repository Layer

The repository layer is responsible for data access operations. It interacts with the database to perform CRUD operations.

**Key Components:**
- `WishlistRepository`: JPA repository interface for wishlist data access

**Design Patterns:**
- Repository pattern
- Data Access Object (DAO) pattern

**Responsibilities:**
- Database CRUD operations
- Query execution
- Data mapping

### 4. Model Layer

The model layer defines the data structures used by the application.

**Key Components:**
- `WishlistItem`: Entity class representing an item in a user's wishlist

**Design Patterns:**
- Domain Model pattern

**Responsibilities:**
- Data structure definition
- Object-Relational Mapping (via JPA annotations)

### 5. Exception Handling

The exception handling component manages errors that occur during application execution.

**Key Components:**
- `GlobalExceptionHandler`: Central exception handler for the application
- Custom exception classes:
  - `UserNotFoundException`
  - `ProductNotFoundException`
  - `DuplicateWishlistItemException`

**Design Patterns:**
- Global Exception Handler pattern

**Responsibilities:**
- Catching and handling exceptions
- Converting exceptions to appropriate HTTP responses
- Providing meaningful error messages

## Data Flow

### Adding an Item to Wishlist

1. Client sends a POST request to `/api/wishlist` with userId and productId parameters
2. `WishlistController.add()` receives the request
3. Controller calls `WishlistService.addItem(userId, productId)`
4. Service checks if the item already exists in the wishlist
   - If it exists, throws `DuplicateWishlistItemException`
   - If not, creates a new `WishlistItem` object
5. Service calls `WishlistRepository.save(item)` to persist the item
6. Repository saves the item to the database
7. Service returns the saved item to the controller
8. Controller returns the item as a JSON response with HTTP 200 OK

### Getting a User's Wishlist

1. Client sends a GET request to `/api/wishlist/{userId}`
2. `WishlistController.get()` receives the request
3. Controller calls `WishlistService.getUserWishlist(userId)`
4. Service calls `WishlistRepository.findByUserId(userId)` to retrieve the items
5. If no items are found, service throws `UserNotFoundException`
6. Service returns the list of items to the controller
7. Controller returns the items as a JSON array with HTTP 200 OK

## Database Schema

The Wishlist Service uses a simple database schema with a single table:

**Table: wishlist**

| Column    | Type      | Constraints                 |
|-----------|-----------|----------------------------|
| id        | BIGINT    | PRIMARY KEY, AUTO_INCREMENT |
| user_id   | BIGINT    | NOT NULL                   |
| product_id| BIGINT    | NOT NULL                   |

**Constraints:**
- Unique constraint on (user_id, product_id) to prevent duplicate entries

## Technology Stack Details

### Spring Boot

The service is built using Spring Boot 3.2.5, which provides:
- Auto-configuration
- Embedded web server (Tomcat)
- Production-ready features

### Spring Data JPA

Spring Data JPA is used for data access, providing:
- Repository interfaces
- Query methods
- Transaction management

### Hibernate

Hibernate is used as the JPA implementation, providing:
- Object-Relational Mapping
- SQL generation
- Connection pooling

### MySQL

MySQL is used as the database, providing:
- Relational data storage
- ACID compliance
- Robust performance

### Swagger/OpenAPI

Swagger/OpenAPI is used for API documentation, providing:
- Interactive API documentation
- API testing interface
- API specification

## Cross-Cutting Concerns

### Logging

The service uses Spring Boot's default logging configuration (Logback), which provides:
- Console logging
- File logging (configurable)
- Log levels (INFO, DEBUG, ERROR, etc.)

### Error Handling

Error handling is centralized in the `GlobalExceptionHandler` class, which:
- Catches exceptions
- Maps exceptions to HTTP status codes
- Returns appropriate error messages

### Configuration Management

Configuration is managed through:
- `application.yml` for application properties
- Spring Boot's property resolution mechanism
- Environment-specific profiles (dev, prod, etc.)

## Scalability and Performance

The Wishlist Service is designed to be scalable and performant:

- **Stateless Design**: The service is stateless, allowing for horizontal scaling
- **Connection Pooling**: HikariCP connection pool for efficient database connections
- **Caching**: Can be added for frequently accessed data
- **Pagination**: Can be implemented for large datasets

## Security Considerations

The current implementation does not include security features, but in a production environment, the following should be considered:

- **Authentication**: JWT or OAuth2 for user authentication
- **Authorization**: Role-based access control
- **HTTPS**: Secure communication
- **Input Validation**: Validate all input parameters
- **SQL Injection Protection**: Provided by JPA/Hibernate

## Future Enhancements

Potential enhancements to the architecture include:

1. **Caching**: Add Redis or Caffeine cache for frequently accessed data
2. **Event-Driven Architecture**: Implement message queues for asynchronous processing
3. **Microservices Communication**: Add client for product service to validate product IDs
4. **Monitoring**: Add metrics collection and monitoring
5. **Resilience Patterns**: Add circuit breakers, retries, and timeouts