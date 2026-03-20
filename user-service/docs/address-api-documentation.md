# Address API Documentation

## Overview
This document provides a comprehensive explanation of the Address API implementation in the User Service. The API allows users to manage their addresses (both billing and shipping) through RESTful endpoints.

## Database Schema
The address information is stored in the `address` table with the following structure:

```sql
CREATE TABLE address (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  address_type ENUM('billing', 'shipping') NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  street_address VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20) NOT NULL,
  country VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
```

## Implementation Components

### 1. Model
The `Address` entity class represents the address data in the application:
- Maps to the `address` table in the database
- Contains fields for all address properties
- Includes an enum for address types (billing, shipping)
- Has a many-to-one relationship with the User entity

### 2. DTOs (Data Transfer Objects)
Three DTOs were created to handle different operations:
- `AddressDTO`: For retrieving address data
- `CreateAddressDTO`: For creating new addresses
- `UpdateAddressDTO`: For updating existing addresses

### 3. Repository
The `AddressRepository` interface extends JpaRepository and provides methods for:
- Finding addresses by user
- Finding addresses by user and address type
- Finding default addresses by user and address type

### 4. Mapper
The `AddressMapper` class converts between entity and DTO objects:
- Maps Address entities to AddressDTO objects
- Creates Address entities from CreateAddressDTO objects
- Updates Address entities from UpdateAddressDTO objects

### 5. Service
The `AddressService` class contains the business logic:
- Retrieves addresses for a user
- Creates new addresses
- Updates existing addresses
- Deletes addresses
- Handles default address logic (only one default per address type)

### 6. Controller
The `UserController` class exposes the RESTful endpoints:
- GET endpoints for retrieving addresses
- POST endpoint for creating addresses
- PUT endpoint for updating addresses
- DELETE endpoint for removing addresses

## API Endpoints

### 1. Get All Addresses for a User
```
GET /api/v1/users/{userId}/addresses
```
- **Description**: Retrieves all addresses associated with a specific user
- **Path Parameters**: userId (Long) - The ID of the user
- **Response**: List of AddressDTO objects
- **Status Codes**:
  - 200 OK: Addresses retrieved successfully
  - 404 Not Found: User not found
  - 401 Unauthorized: Authentication required

### 2. Get Specific Address
```
GET /api/v1/users/{userId}/addresses/{addressId}
```
- **Description**: Retrieves a specific address by ID
- **Path Parameters**:
  - userId (Long) - The ID of the user
  - addressId (Long) - The ID of the address
- **Response**: AddressDTO object
- **Status Codes**:
  - 200 OK: Address retrieved successfully
  - 404 Not Found: Address not found or doesn't belong to the user
  - 401 Unauthorized: Authentication required

### 3. Create Address
```
POST /api/v1/users/{userId}/addresses
```
- **Description**: Creates a new address for a user
- **Path Parameters**: userId (Long) - The ID of the user
- **Request Body**: CreateAddressDTO object
- **Response**: AddressDTO object (the created address)
- **Status Codes**:
  - 201 Created: Address created successfully
  - 404 Not Found: User not found
  - 401 Unauthorized: Authentication required

### 4. Update Address
```
PUT /api/v1/users/{userId}/addresses/{addressId}
```
- **Description**: Updates an existing address
- **Path Parameters**:
  - userId (Long) - The ID of the user
  - addressId (Long) - The ID of the address
- **Request Body**: UpdateAddressDTO object
- **Response**: AddressDTO object (the updated address)
- **Status Codes**:
  - 200 OK: Address updated successfully
  - 404 Not Found: Address not found or doesn't belong to the user
  - 401 Unauthorized: Authentication required

### 5. Delete Address
```
DELETE /api/v1/users/{userId}/addresses/{addressId}
```
- **Description**: Deletes an address
- **Path Parameters**:
  - userId (Long) - The ID of the user
  - addressId (Long) - The ID of the address
- **Response**: No content
- **Status Codes**:
  - 204 No Content: Address deleted successfully
  - 404 Not Found: Address not found or doesn't belong to the user
  - 401 Unauthorized: Authentication required

## Error Handling
The API uses a global exception handler to manage errors:
- `AddressNotFoundException`: Thrown when an address is not found or doesn't belong to the specified user
- `UserNotFoundException`: Thrown when a user is not found
- All exceptions return appropriate HTTP status codes and error messages

## Example Requests (from requests.http)

### Get User Addresses
```http
GET http://localhost:8081/api/v1/users/{{userId}}/addresses
Accept: application/json
Authorization: Bearer {{token}}
```

### Get User Address by ID
```http
GET http://localhost:8081/api/v1/users/{{userId}}/addresses/1
Accept: application/json
Authorization: Bearer {{token}}
```

### Create Address
```http
POST http://localhost:8081/api/v1/users/{{userId}}/addresses
Content-Type: application/json
Accept: application/json
Authorization: Bearer {{token}}

{
  "addressType": "shipping",
  "isDefault": true,
  "streetAddress": "123 Main St",
  "city": "New York",
  "state": "NY",
  "postalCode": "10001",
  "country": "USA"
}
```

### Update Address
```http
PUT http://localhost:8081/api/v1/users/{{userId}}/addresses/1
Content-Type: application/json
Accept: application/json
Authorization: Bearer {{token}}

{
  "addressType": "billing",
  "isDefault": true,
  "streetAddress": "456 Park Ave",
  "city": "New York",
  "state": "NY",
  "postalCode": "10022",
  "country": "USA"
}
```

### Delete Address
```http
DELETE http://localhost:8081/api/v1/users/{{userId}}/addresses/1
Authorization: Bearer {{token}}
```

## Technical Considerations

### Default Address Handling
- Only one address can be set as default for each address type (billing/shipping)
- When setting an address as default, any existing default address of the same type is automatically set to non-default

### Security
- All endpoints require authentication using JWT tokens
- The API verifies that users can only access their own addresses

### Validation
- The API validates that addresses belong to the specified user
- Required fields are enforced at both the database and application levels

## Conclusion
The Address API provides a complete set of CRUD operations for managing user addresses. It follows RESTful principles and includes proper error handling and security measures.