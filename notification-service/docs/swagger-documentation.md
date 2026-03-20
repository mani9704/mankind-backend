# Notification Service API - Swagger Documentation

## Overview

This document provides information on how to access and use the Swagger documentation for the Notification Service API.

## Accessing Swagger UI

The Swagger UI for the Notification Service API can be accessed at:

```
http://localhost:8084/swagger-ui.html
```

Replace `localhost:8084` with the appropriate host and port if the service is deployed elsewhere.

## Available Endpoints

The Swagger documentation provides detailed information about the following endpoints:

### Notification Controller

#### POST /api/notifications/sms
- Description: Sends an SMS notification to a user
- Request Body: SmsRequest object
  - `phoneNumber` (required): The phone number of the recipient in E.164 format (e.g., +1234567890)
  - `message` (required): The content of the SMS message
- Responses:
  - 200: SMS notification sent successfully
  - 400: Invalid input
  - 500: Failed to send SMS notification

### Notification Controller

#### GET /api/notifications
- Description: Retrieves all notifications
- Parameters: 
  - `page` (optional): Page number for pagination
  - `size` (optional): Number of items per page
  - `sort` (optional): Sort field and direction
- Responses:
  - 200: Successful operation
  - 401: Unauthorized
  - 403: Forbidden
  - 500: Internal server error

#### GET /api/notifications/{id}
- Description: Retrieves a notification by ID
- Parameters:
  - `id` (required): The ID of the notification
- Responses:
  - 200: Successful operation
  - 404: Notification not found
  - 401: Unauthorized
  - 403: Forbidden
  - 500: Internal server error

#### POST /api/notifications
- Description: Creates a new notification
- Request Body: Notification object
- Responses:
  - 201: Notification created
  - 400: Invalid input
  - 401: Unauthorized
  - 403: Forbidden
  - 500: Internal server error

#### PUT /api/notifications/{id}
- Description: Updates an existing notification
- Parameters:
  - `id` (required): The ID of the notification to update
- Request Body: Updated notification object
- Responses:
  - 200: Notification updated
  - 400: Invalid input
  - 404: Notification not found
  - 401: Unauthorized
  - 403: Forbidden
  - 500: Internal server error

#### DELETE /api/notifications/{id}
- Description: Deletes a notification
- Parameters:
  - `id` (required): The ID of the notification to delete
- Responses:
  - 204: Notification deleted
  - 404: Notification not found
  - 401: Unauthorized
  - 403: Forbidden
  - 500: Internal server error

## Models

### Notification
- `id` (integer): Unique identifier for the notification
- `userId` (integer): ID of the user to whom the notification is sent
- `type` (string, enum): Type of notification (EMAIL, SMS, PUSH)
- `subject` (string): Subject of the notification
- `content` (string): Content of the notification
- `status` (string, enum): Status of the notification (PENDING, SENT, FAILED)
- `createdAt` (string, date-time): Creation timestamp
- `updatedAt` (string, date-time): Last update timestamp

## Authentication

The API requires authentication. The Swagger UI allows you to authenticate using the "Authorize" button at the top of the page. You will need to provide a valid JWT token.

## Testing with Swagger

1. Navigate to the Swagger UI URL
2. Click on the "Authorize" button and enter your credentials
3. Expand the endpoint you want to test
4. Fill in the required parameters and request body
5. Click "Execute" to send the request
6. View the response
