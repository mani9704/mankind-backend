# Wishlist Service API Documentation

This document provides detailed information about the REST API endpoints exposed by the Wishlist Service.

## Base URL

All API endpoints are relative to the base URL:

```
http://localhost:8082/api/wishlist
```

## Authentication

Currently, the Wishlist Service does not implement authentication. In a production environment, it would typically require authentication tokens to be passed in the request headers.

## API Endpoints

### 1. Add Item to Wishlist

Adds a product to a user's wishlist.

**Endpoint:** `POST /api/wishlist`

**Query Parameters:**
- `userId` (Long, required): The ID of the user
- `productId` (Long, required): The ID of the product to add to the wishlist

**Request Headers:**
- `Accept: application/json`

**Request Body:** None

**Success Response:**
- **Code:** 200 OK
- **Content:** JSON object representing the created wishlist item
  ```json
  {
    "userId": 1,
    "productId": 100
  }
  ```

**Error Responses:**
- **Code:** 409 CONFLICT
  - **Content:** `"Item already in wishlist"`
  - **Cause:** The specified product is already in the user's wishlist
- **Code:** 400 BAD REQUEST
  - **Content:** Error message
  - **Cause:** Invalid request parameters or other runtime errors

**Example:**
```http
POST http://localhost:8082/api/wishlist?userId=1&productId=100
Accept: application/json
```

### 2. Get User's Wishlist

Retrieves all items in a user's wishlist.

**Endpoint:** `GET /api/wishlist/{userId}`

**Path Parameters:**
- `userId` (Long, required): The ID of the user whose wishlist to retrieve

**Request Headers:**
- `Accept: application/json`

**Request Body:** None

**Success Response:**
- **Code:** 200 OK
- **Content:** JSON array of wishlist items
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

**Error Responses:**
- **Code:** 404 NOT FOUND
  - **Content:** `"User not found or no wishlist items available for user {userId}"`
  - **Cause:** The specified user does not exist or has no items in their wishlist

**Example:**
```http
GET http://localhost:8082/api/wishlist/1
Accept: application/json
```

### 3. Remove Item from Wishlist

Removes a product from a user's wishlist.

**Endpoint:** `DELETE /api/wishlist`

**Query Parameters:**
- `userId` (Long, required): The ID of the user
- `productId` (Long, required): The ID of the product to remove from the wishlist

**Request Headers:**
- `Accept: application/json`

**Request Body:** None

**Success Response:**
- **Code:** 200 OK
- **Content:** None (empty response body)

**Error Responses:**
- **Code:** 400 BAD REQUEST
  - **Content:** `"Item not found in wishlist"`
  - **Cause:** The specified product is not in the user's wishlist

**Example:**
```http
DELETE http://localhost:8082/api/wishlist?userId=1&productId=100
Accept: application/json
```

### 4. Check if Item is in Wishlist

Checks if a product is in a user's wishlist.

**Endpoint:** `GET /api/wishlist/check`

**Query Parameters:**
- `userId` (Long, required): The ID of the user
- `productId` (Long, required): The ID of the product to check

**Request Headers:**
- `Accept: application/json`

**Request Body:** None

**Success Response:**
- **Code:** 200 OK
- **Content:** Boolean value (`true` if the item is in the wishlist, `false` otherwise)

**Error Responses:**
- **Code:** 400 BAD REQUEST
  - **Content:** Error message
  - **Cause:** Invalid request parameters or other runtime errors

**Example:**
```http
GET http://localhost:8082/api/wishlist/check?userId=1&productId=100
Accept: application/json
```

## Status Codes

The Wishlist Service uses the following HTTP status codes:

| Status Code | Description |
|-------------|-------------|
| 200 | OK - The request was successful |
| 400 | Bad Request - The request could not be understood or was missing required parameters |
| 404 | Not Found - Resource was not found |
| 409 | Conflict - Request could not be completed due to a conflict with the current state of the resource |
| 500 | Internal Server Error - An unexpected error occurred on the server |

## Error Handling

Errors are returned as plain text with an appropriate HTTP status code. The error message provides information about what went wrong.

### Common Error Messages

| Error Message | Status Code | Description |
|---------------|-------------|-------------|
| "User not found or no wishlist items available for user {userId}" | 404 | The specified user does not exist or has no items in their wishlist |
| "Item already in wishlist" | 409 | The specified product is already in the user's wishlist |
| "Item not found in wishlist" | 400 | The specified product is not in the user's wishlist |

## Testing the API

You can test the API using the provided `requests.http` file in the `api` directory, which contains example requests for all endpoints. This file can be used with tools like Visual Studio Code's REST Client extension or IntelliJ IDEA's HTTP Client.

Alternatively, you can use the Swagger UI interface available at:

```
http://localhost:8082/swagger-ui.html
```

This provides an interactive documentation where you can try out the API endpoints directly from your browser.