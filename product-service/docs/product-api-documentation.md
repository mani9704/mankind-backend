# Product API Documentation

## Overview
The Product API provides endpoints for managing products in the Mankind Matrix system. This API allows clients to create, read, update, and delete product information.

## Base URL
```
/api/products
```

## Authentication
All API endpoints require authentication using JWT tokens. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### Get All Products
Retrieves a paginated list of products.

**Request:**
```
GET /api/products?page=0&size=10&sort=name,asc
```

**Query Parameters:**
- `page` (optional): Page number (0-based, default: 0)
- `size` (optional): Page size (default: 20)
- `sort` (optional): Sort field and direction (e.g., name,asc)

**Response:**
```json
{
  "content": [
    {
      "id": 1,
      "name": "Product 1",
      "description": "Description of product 1",
      "price": 99.99,
      "category": "Electronics",
      "inStock": true,
      "createdAt": "2023-05-15T10:30:00Z",
      "updatedAt": "2023-05-15T10:30:00Z"
    },
    {
      "id": 2,
      "name": "Product 2",
      "description": "Description of product 2",
      "price": 49.99,
      "category": "Clothing",
      "inStock": true,
      "createdAt": "2023-05-16T14:20:00Z",
      "updatedAt": "2023-05-16T14:20:00Z"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "offset": 0,
    "paged": true,
    "unpaged": false
  },
  "totalElements": 2,
  "totalPages": 1,
  "last": true,
  "size": 10,
  "number": 0,
  "sort": {
    "sorted": true,
    "unsorted": false,
    "empty": false
  },
  "numberOfElements": 2,
  "first": true,
  "empty": false
}
```

### Get Product by ID
Retrieves a specific product by its ID.

**Request:**
```
GET /api/products/{id}
```

**Path Parameters:**
- `id`: Product ID

**Response:**
```json
{
  "id": 1,
  "name": "Product 1",
  "description": "Description of product 1",
  "price": 99.99,
  "category": "Electronics",
  "inStock": true,
  "createdAt": "2023-05-15T10:30:00Z",
  "updatedAt": "2023-05-15T10:30:00Z"
}
```

### Create Product
Creates a new product.

**Request:**
```
POST /api/products
Content-Type: application/json

{
  "name": "New Product",
  "description": "Description of new product",
  "price": 149.99,
  "category": "Home & Kitchen",
  "inStock": true
}
```

**Response:**
```json
{
  "id": 3,
  "name": "New Product",
  "description": "Description of new product",
  "price": 149.99,
  "category": "Home & Kitchen",
  "inStock": true,
  "createdAt": "2023-05-20T09:15:00Z",
  "updatedAt": "2023-05-20T09:15:00Z"
}
```

### Update Product
Updates an existing product.

**Request:**
```
PUT /api/products/{id}
Content-Type: application/json

{
  "name": "Updated Product",
  "description": "Updated description",
  "price": 159.99,
  "category": "Home & Kitchen",
  "inStock": false
}
```

**Path Parameters:**
- `id`: Product ID

**Response:**
```json
{
  "id": 3,
  "name": "Updated Product",
  "description": "Updated description",
  "price": 159.99,
  "category": "Home & Kitchen",
  "inStock": false,
  "createdAt": "2023-05-20T09:15:00Z",
  "updatedAt": "2023-05-20T10:25:00Z"
}
```

### Delete Product
Deletes a product.

**Request:**
```
DELETE /api/products/{id}
```

**Path Parameters:**
- `id`: Product ID

**Response:**
```
204 No Content
```

## Error Responses

### Not Found (404)
```json
{
  "timestamp": "2023-05-20T12:30:45Z",
  "status": 404,
  "error": "Not Found",
  "message": "Product with ID 999 not found",
  "path": "/api/products/999"
}
```

### Bad Request (400)
```json
{
  "timestamp": "2023-05-20T12:32:10Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "message": "Name cannot be empty"
    },
    {
      "field": "price",
      "message": "Price must be greater than zero"
    }
  ],
  "path": "/api/products"
}
```

### Unauthorized (401)
```json
{
  "timestamp": "2023-05-20T12:33:20Z",
  "status": 401,
  "error": "Unauthorized",
  "message": "Authentication required",
  "path": "/api/products"
}
```