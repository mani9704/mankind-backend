# Cart API Documentation

## Overview
The Cart API provides endpoints for managing shopping carts and cart items in the Mankind Matrix system. This API allows clients to create, read, update, and delete carts and cart items.

## Base URLs
```
/api/carts
/api/cart-items
```

## Authentication
All API endpoints require authentication using JWT tokens. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Cart Endpoints

### Get Cart by ID
Retrieves a specific cart by its ID.

**Request:**
```
GET /api/carts/{id}
```

**Path Parameters:**
- `id`: Cart ID

**Response:**
```json
{
  "id": 1,
  "userId": 101,
  "sessionId": null,
  "status": "ACTIVE",
  "createdAt": "2023-05-15T10:30:00Z",
  "updatedAt": "2023-05-15T10:30:00Z",
  "subtotal": 39.98,
  "tax": 4.00,
  "total": 43.98,
  "cartItems": [
    {
      "id": 1,
      "cartId": 1,
      "productId": 201,
      "quantity": 2,
      "price": 19.99
    }
  ],
  "totalItems": 2
}
```

### Get Active Cart by User ID
Retrieves the active cart for a specific user.

**Request:**
```
GET /api/carts/user/{userId}/active
```

**Path Parameters:**
- `userId`: User ID

**Response:**
```json
{
  "id": 1,
  "userId": 101,
  "sessionId": null,
  "status": "ACTIVE",
  "createdAt": "2023-05-15T10:30:00Z",
  "updatedAt": "2023-05-15T10:30:00Z",
  "subtotal": 39.98,
  "tax": 4.00,
  "total": 43.98,
  "cartItems": [
    {
      "id": 1,
      "cartId": 1,
      "productId": 201,
      "quantity": 2,
      "price": 19.99
    }
  ],
  "totalItems": 2
}
```

### Get Active Cart by Session ID
Retrieves the active cart for a specific session (for guest users).

**Request:**
```
GET /api/carts/session/{sessionId}/active
```

**Path Parameters:**
- `sessionId`: Session ID

**Response:**
```json
{
  "id": 3,
  "userId": null,
  "sessionId": "guest-session-123",
  "status": "ACTIVE",
  "createdAt": "2023-05-17T09:45:00Z",
  "updatedAt": "2023-05-17T09:45:00Z",
  "subtotal": 29.99,
  "tax": 3.00,
  "total": 32.99,
  "cartItems": [
    {
      "id": 3,
      "cartId": 3,
      "productId": 203,
      "quantity": 1,
      "price": 29.99
    }
  ],
  "totalItems": 1
}
```

### Create Cart
Creates a new cart.

**Request:**
```
POST /api/carts
Content-Type: application/json

{
  "userId": 103,
  "sessionId": null,
  "status": "ACTIVE"
}
```

**Response:**
```json
{
  "id": 4,
  "userId": 103,
  "sessionId": null,
  "status": "ACTIVE",
  "createdAt": "2023-05-20T09:15:00Z",
  "updatedAt": "2023-05-20T09:15:00Z",
  "subtotal": 0.00,
  "tax": 0.00,
  "total": 0.00,
  "cartItems": [],
  "totalItems": 0
}
```

### Update Cart
Updates an existing cart.

**Request:**
```
PUT /api/carts/{id}
Content-Type: application/json

{
  "userId": 103,
  "sessionId": null,
  "status": "ABANDONED"
}
```

**Path Parameters:**
- `id`: Cart ID

**Response:**
```json
{
  "id": 4,
  "userId": 103,
  "sessionId": null,
  "status": "ABANDONED",
  "createdAt": "2023-05-20T09:15:00Z",
  "updatedAt": "2023-05-20T10:25:00Z",
  "subtotal": 0.00,
  "tax": 0.00,
  "total": 0.00,
  "cartItems": [],
  "totalItems": 0
}
```

### Update Cart Status
Updates the status of a cart.

**Request:**
```
PATCH /api/carts/{id}/status/{status}
```

**Path Parameters:**
- `id`: Cart ID
- `status`: New status (ACTIVE, CONVERTED, ABANDONED, REMOVED)

**Response:**
```json
{
  "id": 4,
  "userId": 103,
  "sessionId": null,
  "status": "CONVERTED",
  "createdAt": "2023-05-20T09:15:00Z",
  "updatedAt": "2023-05-20T11:30:00Z",
  "subtotal": 0.00,
  "tax": 0.00,
  "total": 0.00,
  "cartItems": [],
  "totalItems": 0
}
```

### Delete Cart
Deletes a cart.

**Request:**
```
DELETE /api/carts/{id}
```

**Path Parameters:**
- `id`: Cart ID

**Response:**
```
204 No Content
```

## Cart Item Endpoints

### Get All Cart Items
Retrieves a list of all cart items.

**Request:**
```
GET /api/cart-items
```

**Response:**
```json
[
  {
    "id": 1,
    "cartId": 1,
    "productId": 201,
    "quantity": 2,
    "price": 19.99
  },
  {
    "id": 2,
    "cartId": 2,
    "productId": 202,
    "quantity": 1,
    "price": 14.99
  }
]
```

### Get Cart Item by ID
Retrieves a specific cart item by its ID.

**Request:**
```
GET /api/cart-items/{id}
```

**Path Parameters:**
- `id`: Cart item ID

**Response:**
```json
{
  "id": 1,
  "cartId": 1,
  "productId": 201,
  "quantity": 2,
  "price": 19.99
}
```

### Get Cart Items by Cart ID
Retrieves all cart items for a specific cart.

**Request:**
```
GET /api/cart-items/cart/{cartId}
```

**Path Parameters:**
- `cartId`: Cart ID

**Response:**
```json
[
  {
    "id": 1,
    "cartId": 1,
    "productId": 201,
    "quantity": 2,
    "price": 19.99
  },
  {
    "id": 4,
    "cartId": 1,
    "productId": 204,
    "quantity": 1,
    "price": 9.99
  }
]
```

### Create Cart Item
Creates a new cart item. If an item with the same cartId and productId already exists, the quantity will be incremented instead of creating a new item.

**Request:**
```
POST /api/cart-items
Content-Type: application/json

{
  "cartId": 1,
  "productId": 205,
  "quantity": 1,
  "price": 24.99
}
```

**Response:**
```json
{
  "id": 5,
  "cartId": 1,
  "productId": 205,
  "quantity": 1,
  "price": 24.99
}
```

### Update Cart Item
Updates an existing cart item.

**Request:**
```
PUT /api/cart-items/{id}
Content-Type: application/json

{
  "cartId": 1,
  "productId": 205,
  "quantity": 2,
  "price": 24.99
}
```

**Path Parameters:**
- `id`: Cart item ID

**Response:**
```json
{
  "id": 5,
  "cartId": 1,
  "productId": 205,
  "quantity": 2,
  "price": 24.99
}
```

### Delete Cart Item
Deletes a cart item.

**Request:**
```
DELETE /api/cart-items/{id}
```

**Path Parameters:**
- `id`: Cart item ID

**Response:**
```
204 No Content
```

### Delete Cart Items by Cart ID
Deletes all cart items for a specific cart.

**Request:**
```
DELETE /api/cart-items/cart/{cartId}
```

**Path Parameters:**
- `cartId`: Cart ID

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
  "message": "Cart with ID 999 not found",
  "path": "/api/carts/999"
}
```

### Bad Request (400)
```json
{
  "timestamp": "2023-05-20T12:32:10Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "errors": {
    "quantity": "Quantity must be greater than zero",
    "cartId": "Cart ID cannot be null"
  },
  "path": "/api/cart-items"
}
```

### Unauthorized (401)
```json
{
  "timestamp": "2023-05-20T12:33:20Z",
  "status": 401,
  "error": "Unauthorized",
  "message": "Authentication required",
  "path": "/api/carts"
}
```
