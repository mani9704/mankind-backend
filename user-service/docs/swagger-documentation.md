# Swagger Documentation for User Service

## Overview
This document provides information on how to access and use the Swagger UI for the User Service API. Swagger provides interactive documentation that allows you to explore and test the API endpoints directly from your browser.

## Accessing Swagger UI
The Swagger UI is available at the following URL when the application is running:

```
http://localhost:8081/swagger-ui.html
```

## Features
- **Interactive Documentation**: Explore all available API endpoints with detailed descriptions
- **Request/Response Examples**: See example requests and responses for each endpoint
- **Try It Out**: Test API endpoints directly from the browser
- **Authentication**: Authenticate with JWT tokens to test secured endpoints

## Authentication
Most endpoints in the User Service require authentication. To use these endpoints in Swagger UI:

1. First, use the `/api/v1/auth/login` endpoint to obtain a JWT token
2. Click the "Authorize" button at the top of the page
3. Enter your JWT token with the Bearer prefix (e.g., `Bearer eyJhbGciOiJIUzI1NiJ9...`)
4. Click "Authorize" to apply the token to all subsequent requests

To logout and invalidate your token:
1. Use the `/api/v1/auth/logout` endpoint
2. The endpoint will automatically extract your token from the Authorization header
3. The token will be invalidated and can no longer be used for authentication

The logout endpoint can return different responses based on the token status:
- 200 OK: Logout successful
- 400 Bad Request: 
  - No token provided
  - Invalid token format
  - Token already invalidated
- 500 Internal Server Error: An unexpected error occurred during logout

## Available API Groups

### Authentication
Endpoints for user registration and authentication:
- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Authenticate a user and get a JWT token
- `POST /api/v1/auth/logout` - Invalidate a user's JWT token

### User Management
Endpoints for managing users and their addresses:
- `GET /api/v1/users` - Get all users
- `GET /api/v1/users/{id}` - Get a specific user
- `PUT /api/v1/users/{id}` - Update a user

#### Address Management
- `GET /api/v1/users/{userId}/addresses` - Get all addresses for a user
- `GET /api/v1/users/{userId}/addresses/{addressId}` - Get a specific address
- `POST /api/v1/users/{userId}/addresses` - Create a new address
- `PUT /api/v1/users/{userId}/addresses/{addressId}` - Update an address
- `DELETE /api/v1/users/{userId}/addresses/{addressId}` - Delete an address

## Using Swagger UI

### Exploring Endpoints
1. Navigate to the Swagger UI URL
2. Browse through the available endpoints grouped by tags
3. Click on an endpoint to expand it and see detailed information

### Testing Endpoints
1. Click the "Try it out" button on any endpoint
2. Fill in the required parameters and request body
3. Click "Execute" to send the request
4. View the response, including status code, headers, and body

### Schema Information
Swagger UI also provides detailed information about the data models (schemas) used in the API:
- Click on the "Schema" section to view all available data models
- Each model shows its properties, types, and descriptions

## Troubleshooting
- If you receive a 401 Unauthorized error, make sure you've properly authenticated with a valid JWT token
- If you receive a 403 Forbidden error, your user may not have the necessary permissions
- If the Swagger UI doesn't load, ensure the application is running and the Swagger UI path is correct

## Conclusion
Swagger UI provides a convenient way to explore and test the User Service API. It helps developers understand the available endpoints, required parameters, and expected responses without having to write code or use external tools like Postman.
