# Swagger Documentation for Recently Viewed Products API

## Overview
This document provides guidelines for using Swagger/OpenAPI to document the Recently Viewed Products API in the Mankind Matrix Product Service. The Recently Viewed Products API allows users to track and manage products they have recently viewed.

## Accessing Swagger UI
The Swagger UI for the Recently Viewed Products API is available at:
```
http://localhost:8080/swagger-ui.html
```

## API Endpoints

### Add Product to Recently Viewed
- **URL**: `/api/v1/recently-viewed`
- **Method**: `POST`
- **Parameters**:
  - `userId` (query, required): ID of the user
  - `productId` (query, required): ID of the product
- **Responses**:
  - `200 OK`: Product successfully added to recently viewed
  - `400 Bad Request`: Invalid input parameters (e.g., invalid user ID or product ID)
  - `404 Not Found`: Product not found
  - `500 Internal Server Error`: Server error

### Get Recently Viewed Products
- **URL**: `/api/v1/recently-viewed`
- **Method**: `GET`
- **Parameters**:
  - `userId` (query, required): ID of the user
  - `page` (query, optional): Page number (zero-based)
  - `size` (query, optional): Number of items per page
  - `sort` (query, optional): Sorting criteria. Valid sort properties are: `id`, `userId`, `productId`, `viewedAt`, `lastViewedAt`. Example: `sort=lastViewedAt,desc`
- **Responses**:
  - `200 OK`: Successfully retrieved recently viewed products
  - `400 Bad Request`: Invalid input parameters (e.g., invalid user ID or invalid sort property)
  - `500 Internal Server Error`: Server error

### Remove Product from Recently Viewed
- **URL**: `/api/v1/recently-viewed`
- **Method**: `DELETE`
- **Parameters**:
  - `userId` (query, required): ID of the user
  - `productId` (query, required): ID of the product
- **Responses**:
  - `204 No Content`: Product successfully removed from recently viewed
  - `400 Bad Request`: Invalid input parameters (e.g., invalid user ID or product ID)
  - `404 Not Found`: Product not found in recently viewed
  - `500 Internal Server Error`: Server error

### Clear Recently Viewed Products
- **URL**: `/api/v1/recently-viewed/clear`
- **Method**: `DELETE`
- **Parameters**:
  - `userId` (query, required): ID of the user
- **Responses**:
  - `204 No Content`: Recently viewed products successfully cleared
  - `400 Bad Request`: Invalid input parameters (e.g., invalid user ID)
  - `404 Not Found`: No recently viewed products found for user
  - `500 Internal Server Error`: Server error

## Models

### RecentlyViewedProductResponseDTO
- **Properties**:
  - `id` (Long): ID of the recently viewed product entry
  - `userId` (Long): ID of the user who viewed the product
  - `product` (ProductResponseDTO): Product details
  - `viewedAt` (LocalDateTime): Date and time when the product was first viewed
  - `lastViewedAt` (LocalDateTime): Date and time when the product was last viewed

## Implementation Details

The Recently Viewed Products API is implemented using the following components:

1. **Controller**: `RecentlyViewedProductController`
   - Handles HTTP requests and responses
   - Maps requests to service methods
   - Provides Swagger documentation

2. **Service**: `RecentlyViewedProductService`
   - Contains business logic for managing recently viewed products
   - Handles adding, retrieving, and removing entries
   - Manages the maximum number of recently viewed items per user
   - Implements comprehensive exception handling for all operations
   - Validates input parameters and provides detailed error messages

3. **Repository**: `RecentlyViewedProductRepository`
   - Provides data access methods for the `RecentlyViewedProduct` entity
   - Implements custom queries for retrieving and managing recently viewed products

4. **Model**: `RecentlyViewedProduct`
   - Represents a recently viewed product entry in the database
   - Contains user ID, product ID, and timestamps

5. **DTO**: `RecentlyViewedProductResponseDTO`
   - Data Transfer Object for returning recently viewed product data to clients
   - Includes product details and timestamps

6. **Mapper**: `RecentlyViewedProductMapper`
   - Converts between entity and DTO

## Configuration

The Recently Viewed Products API can be configured using the following properties:

- `app.recently-viewed.max-items`: Maximum number of recently viewed items per user (default: 10)
