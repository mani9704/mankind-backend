# Swagger Documentation for Cart Service

## Overview
The Cart Service API is documented using Swagger/OpenAPI, providing an interactive interface for exploring and testing the API endpoints. This document explains how to access and use the Swagger documentation.

## Accessing Swagger UI

The Swagger UI is available at:
```
http://localhost:8082/swagger-ui.html
```

The raw OpenAPI specification is available at:
```
http://localhost:8082/api-docs
```

## Features of the Swagger Documentation

### API Information
- **Title**: Mankind Matrix Cart Service API
- **Description**: API for managing shopping carts in the Mankind Matrix platform
- **Version**: 1.0.0
- **Contact Information**: Mankind Matrix Team

### Available Endpoints
The Swagger UI displays all available endpoints grouped by controller:

- **Cart API**
  - GET /api/carts/{id}
  - GET /api/carts/user/{userId}/active
  - GET /api/carts/session/{sessionId}/active
  - POST /api/carts
  - PUT /api/carts/{id}
  - PATCH /api/carts/{id}/status/{status}
  - DELETE /api/carts/{id}

- **Cart Item API**
  - GET /api/cart-items
  - GET /api/cart-items/{id}
  - GET /api/cart-items/cart/{cartId}
  - POST /api/cart-items
  - PUT /api/cart-items/{id}
  - DELETE /api/cart-items/{id}
  - DELETE /api/cart-items/cart/{cartId}


### For Each Endpoint
- **Summary**: Brief description of what the endpoint does
- **Description**: Detailed explanation of the endpoint's functionality
- **Parameters**: List of path, query, and request body parameters
- **Request Body Schema**: Structure of the request body for POST and PUT requests
- **Response Schemas**: Structure of the response for different HTTP status codes
- **Try It Out**: Feature to test the API directly from the browser

## Using Swagger UI

### Exploring Endpoints
1. Navigate to the Swagger UI URL
2. Browse the available endpoints grouped by controller
3. Click on an endpoint to expand its details

### Testing Endpoints
1. Click the "Try it out" button for the endpoint you want to test
2. Fill in the required parameters and request body
3. Click "Execute" to send the request
4. View the response, including status code, headers, and body

### Authentication
If authentication is required:
1. Click the "Authorize" button at the top of the page
2. Enter your JWT token
3. Click "Authorize" to apply the token to all requests

## OpenAPI Specification
The OpenAPI specification is a machine-readable description of the API that follows the OpenAPI standard. It can be used to:

- Generate client libraries in various programming languages
- Set up automated testing
- Configure API gateways
- Create custom documentation

You can download the specification from the `/api-docs` endpoint.

## Configuration
The Swagger documentation is configured in the `OpenApiConfig` class and the `application.yml` file. Key configurations include:

- API information (title, description, version)
- Server information
- Security schemes
- Documentation sorting and filtering options

## Models
The Swagger UI also provides detailed information about the data models used in the API:

- **Cart**: Shopping cart entity
  - id: Unique identifier
  - userId: ID of the user who owns the cart
  - sessionId: Session ID for guest users
  - status: Cart status (ACTIVE, CONVERTED, ABANDONED, REMOVED)
  - createdAt: Creation timestamp
  - updatedAt: Last update timestamp
  - cartItems: List of items in the cart
  - totalItems: Total number of items in the cart
  - subtotal: Sum of all items price * quantity
  - tax: Calculated tax amount
  - total: Total price including tax

- **CartItem**: Item in a shopping cart
  - id: Unique identifier
  - cartId: ID of the cart this item belongs to
  - productId: ID of the product
  - quantity: Number of units
  - price: Price of the product


## Best Practices
When using the API through Swagger:

1. Always check the required parameters for each endpoint
2. Review the response schemas to understand what to expect
3. Use the "Try it out" feature to validate your requests before implementing them in code
4. Remember that operations performed through Swagger affect the actual database
5. For cart operations, start by creating a cart, then add items to it
6. Use the cart ID from the response when creating cart items
