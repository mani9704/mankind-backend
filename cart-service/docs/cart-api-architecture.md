# Cart API Architecture

## Overview
This document provides a comprehensive overview of the Cart API architecture in the Mankind Matrix Cart Service. It details the components, interactions, and design decisions that form the foundation of the service.

## Architecture Layers

### Presentation Layer
- **CartController**: Handles HTTP requests and responses for cart operations
  - Implements RESTful endpoints for cart operations
  - Performs initial request validation
  - Maps between DTOs and service layer
  - Handles HTTP status codes and response formatting

- **CartItemController**: Handles HTTP requests and responses for cart item operations
  - Implements RESTful endpoints for cart item operations
  - Performs initial request validation
  - Maps between DTOs and service layer
  - Handles HTTP status codes and response formatting


### Business Logic Layer
- **CartService**: Implements core business logic for cart operations
  - Validates business rules and constraints
  - Orchestrates operations across repositories
  - Handles transactional boundaries
  - Implements business-specific operations like cart status updates

- **CartItemService**: Implements core business logic for cart item operations
  - Validates business rules and constraints
  - Orchestrates operations across repositories
  - Handles transactional boundaries
  - Implements business-specific operations like quantity updates


### Data Access Layer
- **CartRepository**: Manages database interactions for carts
  - Extends JpaRepository for standard CRUD operations
  - Implements custom query methods (findByUserIdAndStatus, findBySessionIdAndStatus)
  - Handles database-specific operations

- **CartItemRepository**: Manages database interactions for cart items
  - Extends JpaRepository for standard CRUD operations
  - Implements custom query methods (findByCart, findByCartId)
  - Handles database-specific operations


### Domain Model Layer
- **Cart**: Parent entity that represents a shopping cart
  - Belongs to a user or a guest session
  - Has a status (ACTIVE, CONVERTED, ABANDONED, REMOVED)
  - Contains multiple cart items
  - Includes calculated fields (subtotal, tax, total)
  - Implements lifecycle hooks (onCreate, onUpdate)
  - Provides helper methods for managing cart items and calculating totals

- **CartItem**: Child entity that represents a product in a cart
  - Belongs to a cart
  - References a product by productId
  - Stores quantity and price
  - Minimal design that relies on product service for product details


- **CartStatus**: Enum that defines possible cart statuses
  - ACTIVE: Cart is currently in use
  - CONVERTED: Cart has been converted to an order
  - ABANDONED: Cart has been abandoned by the user
  - REMOVED: Cart has been removed from the system

### Data Transfer Objects
- **CartRequestDto**: External representation for cart input data
  - Used for client-server communication
  - Contains fields for creating/updating carts

- **CartResponseDto**: External representation for cart output data
  - Used for client-server communication
  - Contains all cart fields including cart items
  - Calculates totals (total items, subtotal)

- **CartItemRequestDto**: External representation for cart item input data
  - Used for client-server communication
  - Contains fields for creating/updating cart items
  - Includes validation annotations

- **CartItemResponseDto**: External representation for cart item output data
  - Used for client-server communication
  - Contains all cart item fields including timestamps


### Cross-Cutting Concerns
- **Exception Handling**: GlobalExceptionHandler for consistent error responses
  - Handles ResourceNotFoundException, BadRequestException, and other exceptions
  - Provides consistent error response format
  - Maps exceptions to appropriate HTTP status codes

- **Validation**: Input validation using Bean Validation
  - Validates request DTOs using annotations
  - Provides detailed validation error messages
  - Enforces business rules at the DTO level

- **Mapping**: Object mapping between entities and DTOs
  - CartMapper for mapping between Cart and CartRequestDto/CartResponseDto
  - CartItemMapper for mapping between CartItem and CartItemRequestDto/CartItemResponseDto

- **Security**: Authentication and authorization for API endpoints
  - JWT-based authentication
  - Role-based access control
  - Input validation to prevent injection attacks

- **Logging**: Comprehensive logging for monitoring and debugging
  - Request/response logging
  - Error logging
  - Performance monitoring

## Data Flow
1. Client sends HTTP request to a controller endpoint
2. Controller validates request format and routes to appropriate service method
3. Service applies business rules and calls repository methods
4. Repository executes database operations
5. Results propagate back through the layers
6. Controller formats the response and returns to client

## API Endpoints

### Cart Endpoints
- `GET /api/carts/{id}`: Retrieve a specific cart by ID
- `GET /api/carts/user/{userId}/active`: Retrieve active cart for a specific user
- `GET /api/carts/session/{sessionId}/active`: Retrieve active cart for a specific session
- `POST /api/carts`: Create a new cart
- `PUT /api/carts/{id}`: Update an existing cart
- `PATCH /api/carts/{id}/status/{status}`: Update the status of a cart
- `DELETE /api/carts/{id}`: Delete a cart

### Cart Item Endpoints
- `GET /api/cart-items`: Retrieve all cart items
- `GET /api/cart-items/{id}`: Retrieve a specific cart item by ID
- `GET /api/cart-items/cart/{cartId}`: Retrieve all cart items for a specific cart
- `POST /api/cart-items`: Create a new cart item
- `PUT /api/cart-items/{id}`: Update an existing cart item
- `DELETE /api/cart-items/{id}`: Delete a cart item
- `DELETE /api/cart-items/cart/{cartId}`: Delete all cart items for a specific cart


## Error Handling Strategy
- Use of specific exceptions (ResourceNotFoundException, BadRequestException)
- Consistent error response format using GlobalExceptionHandler
- Appropriate HTTP status codes for different error scenarios
- Detailed error messages for debugging
- Sanitized error messages for production

## Security Considerations
- Authentication using JWT tokens
- Role-based authorization for different operations
- Input validation to prevent injection attacks
- Rate limiting to prevent abuse
- CORS configuration for web clients

## Performance Optimizations
- Connection pooling for database access
- Caching for frequently accessed data
- Efficient query methods for retrieving carts and cart items
- Optimized database schema with appropriate indexes
- Lazy loading of cart items when appropriate
