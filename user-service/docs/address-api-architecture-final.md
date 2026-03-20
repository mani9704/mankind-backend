# Address API Architecture

## Component Diagram

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│             │      │             │      │             │      │             │
│   Client    │──────▶ Controller  │──────▶   Service   │──────▶ Repository  │──────▶ Database
│             │      │             │      │             │      │             │
└─────────────┘      └─────────────┘      └─────────────┘      └─────────────┘
                           │                     │
                           │                     │
                           ▼                     ▼
                     ┌─────────────┐      ┌─────────────┐
                     │             │      │             │
                     │    DTOs     │◀─────▶   Mapper    │
                     │             │      │             │
                     └─────────────┘      └─────────────┘
```

## Flow Diagrams for Address Operations

### Create Address Flow

```
┌─────────┐     ┌────────────────┐     ┌────────────────┐     ┌────────────────┐     ┌─────────┐
│         │     │                │     │                │     │                │     │         │
│ Client  │────▶│ UserController │────▶│ AddressService │────▶│AddressRepository────▶│ Database│
│         │     │                │     │                │     │                │     │         │
└─────────┘     └────────────────┘     └────────────────┘     └────────────────┘     └─────────┘
      │                 │                      │                      │                   │
      │                 │                      │                      │                   │
      │                 ▼                      ▼                      │                   │
      │          ┌────────────────┐    ┌────────────────┐            │                   │
      │          │                │    │                │            │                   │
      │          │ CreateAddressDTO    │ AddressMapper  │            │                   │
      │          │                │    │                │            │                   │
      │          └────────────────┘    └────────────────┘            │                   │
      │                                       │                      │                   │
      │                                       ▼                      │                   │
      │                                ┌────────────────┐            │                   │
      │                                │                │            │                   │
      │                                │ Address Entity │────────────┘                   │
      │                                │                │                                │
      │                                └────────────────┘                                │
      │                                       │                                          │
      │                                       │                                          │
      ▼                                       ▼                                          │
┌─────────────┐                       ┌────────────────┐                                │
│             │                       │                │                                │
│ HTTP 201    │◀──────────────────────│ AddressDTO     │◀───────────────────────────────┘
│ Created     │                       │                │
└─────────────┘                       └────────────────┘
```

### Get Address Flow

The Get Address flow follows a similar pattern to the Create Address flow, but in reverse:

1. **Client** sends a GET request to the **UserController** with userId and addressId
2. **UserController** validates that the user exists and forwards the request to **AddressService**
3. **AddressService** calls **AddressRepository** to retrieve the address from the **Database**
4. The **Address Entity** is retrieved from the database
5. **AddressMapper** converts the entity to an **AddressDTO**
6. The **AddressDTO** is returned to the client with an **HTTP 200 OK** response
7. **UserController** verifies that the address belongs to the specified user before returning it

### Update Address Flow

The Update Address flow combines elements of both Get and Create flows:

1. **Client** sends a PUT request with userId, addressId and an **UpdateAddressDTO**
2. **UserController** validates that the address exists and belongs to the user
3. **AddressService** retrieves the existing address via **AddressRepository**
4. **AddressMapper** updates the **Address Entity** with values from the **UpdateAddressDTO**
5. **AddressService** handles default address logic (only one default per type)
6. Updated **Address Entity** is saved to the **Database**
7. **AddressMapper** converts the updated entity to an **AddressDTO**
8. The **AddressDTO** is returned to the client with an **HTTP 200 OK** response

### Delete Address Flow

The Delete Address flow is the simplest:

1. **Client** sends a DELETE request with userId and addressId
2. **UserController** validates that the address exists and belongs to the user
3. **AddressService** calls **AddressRepository** to delete the address from the **Database**
4. An **HTTP 204 No Content** response is returned to the client

## Component Responsibilities

### Controller Layer
- Handles HTTP requests and responses
- Validates that addresses belong to the specified user
- Delegates business logic to the service layer
- Returns appropriate HTTP status codes

### Service Layer
- Contains business logic for CRUD operations
- Manages default address status (only one default per type)
- Throws exceptions for not found or unauthorized access

### Repository Layer
- Provides data access methods
- Executes database queries
- Returns entity objects

### Mapper Layer
- Converts between entity and DTO objects
- Handles data transformation

### DTO Layer
- Defines data transfer objects for different operations
- Separates internal and external data representations

### Entity Layer
- Defines the database schema
- Maps to database tables
- Contains JPA annotations