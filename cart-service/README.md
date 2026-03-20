# Mankind Matrix Cart Service

This service manages shopping carts for the Mankind Matrix AI platform.

## Features

- Hierarchical cart structure with parent cart and child cart items
- Support for both authenticated users and guest sessions
- Cart status tracking (active, converted, abandoned, removed)
- Add/remove products to/from carts
- Update product quantities in carts
- Calculate cart totals
- Price history tracking
- DTO-based validation
- Checkout process integration

## Cart Structure

The service uses a hierarchical structure:

- **Cart**: Parent entity that represents a shopping cart
  - Belongs to a user or a guest session
  - Has a status (active, converted, abandoned, removed)
  - Contains multiple cart items

- **Cart Item**: Child entity that represents a product in a cart
  - Belongs to a cart
  - References a product
  - Stores the price at the time of addition
  - Tracks quantity and calculates total price

## API Endpoints

The service exposes RESTful endpoints for cart management:

### Cart Endpoints

- `GET /api/carts` - Get all carts
- `GET /api/carts/{id}` - Get cart by ID
- `GET /api/carts/user/{userId}/active` - Get active cart for a specific user
- `GET /api/carts/session/{sessionId}/active` - Get active cart for a specific session
- `GET /api/carts/user/{userId}` - Get all carts for a specific user
- `GET /api/carts/session/{sessionId}` - Get all carts for a specific session
- `GET /api/carts/status/{status}` - Get all carts with a specific status
- `POST /api/carts` - Create a new cart
- `PUT /api/carts/{id}` - Update an existing cart
- `PATCH /api/carts/{id}/status/{status}` - Update the status of a cart
- `DELETE /api/carts/{id}` - Delete a cart
- `DELETE /api/carts/user/{userId}` - Delete all carts for a specific user
- `DELETE /api/carts/session/{sessionId}` - Delete all carts for a specific session

### Cart Item Endpoints

- `GET /api/cart-items` - Get all cart items
- `GET /api/cart-items/{id}` - Get cart item by ID
- `GET /api/cart-items/cart/{cartId}` - Get cart items by cart ID
- `POST /api/cart-items` - Create a new cart item
- `PUT /api/cart-items/{id}` - Update an existing cart item
- `DELETE /api/cart-items/{id}` - Delete a cart item
- `DELETE /api/cart-items/cart/{cartId}` - Delete all cart items for a specific cart

### Price History Endpoints

- `GET /api/price-history/cart-item/{cartItemId}` - Get price history for a specific cart item


## The service will be available at `http://localhost:8082/swagger-ui.html`

## Configuration

Configuration is managed through environment variables defined in the `.env` file.

## Documentation

### API Documentation
Comprehensive API documentation is available in the `docs` directory:
- [Cart API Documentation](docs/cart-api-documentation.md) - Detailed endpoint documentation
- [Cart API Architecture](docs/cart-api-architecture.md) - Architecture overview
- [Swagger Documentation](docs/swagger-documentation.md) - How to use Swagger UI

### Swagger UI
The service uses Swagger/OpenAPI for interactive API documentation. After starting the service, you can access:

- Swagger UI: `http://localhost:8082/swagger-ui.html` - Interactive API documentation
- OpenAPI Specification: `http://localhost:8082/api-docs` - Raw API specification in JSON format

## Testing Tools

### Postman Collection
A Postman collection is available in the `postman` directory:
- [Cart API Collection](postman/Cart_API_Collection.postman_collection.json)

### API Test Requests
Sample HTTP requests for testing the API are available in the `api` directory:
- [requests.http](api/requests.http) - Can be used with REST Client in VS Code

## Database Setup

Database setup scripts are available in the `scripts` directory:
- [setup.sql](scripts/setup.sql) - Database and user creation
- [cart_tables.sql](scripts/cart_tables.sql) - Cart and cart item table creation
- [sample_cart_insert.sql](scripts/sample_cart_insert.sql) - Sample data insertion
- [README.MD](scripts/README.MD) - Database setup instructions

The database schema uses a hierarchical structure with three main tables:
1. `cart` - Stores cart information including user/session and status
2. `cart_item` - Stores items in carts with product information and pricing
3. `price_history` - Tracks price changes for cart items
