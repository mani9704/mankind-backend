# Mankind API Gateway Service

The Mankind API Gateway Service acts as the single entry point for all client requests, routing them to the appropriate backend services securely and efficiently.


## Prerequisites

* Java 17+
* Maven 3.6+
* Spring Boot 3.4.x
* Spring Cloud Gateway 2024.0.x
* (Optional) Docker & Docker Compose for containerized run

## Running the Gateway

1. **Clone the repository**:

   ```bash
   git clone https://github.com/mankind/mankind-gateway-service.git
   cd mankind-gateway-service
   ```

2. **Build & run**:

   ```bash
   mvn clean install
   ```

3. The gateway will start on port `8085` by default. You should see logs indicating route initialization.

## Configuration

All externalized configuration lives in `src/main/resources/application.yml`:

* **server.port**: Port for the gateway (default: 8085).
* **spring.cloud.gateway.routes**: Definitions for path-based routing to downstream services.
* **spring.security.oauth2.resource-server.jwt**: JWT decoder settings (issuer, JWK URI).

Example:

```yaml
server:
  port: 8085

spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri:  http://localhost:8081
          predicates:
            - Path=/api/v1/users/**
          filters:
            - StripPrefix=1
```

## Routing

Routes are defined under `spring.cloud.gateway.routes`. Each route needs:

* **id**: Unique identifier.
* **uri**: Target service URI.
* **predicates**: Conditions on incoming paths.
* **filters**: Optional request/response transformations.

## Security

The gateway enforces JWT-based authentication on all endpoints except the authentication route.

* **Public endpoints**: `/api/v1/auth/**` are permitted without a token.
* **Protected endpoints**: All other routes require a valid `Authorization: Bearer <token>` header.

The current implementation uses Spring Security's OAuth2 Resource Server with JWT decoding.

## Keycloak Integration

> 🚧 **Work in Progress**: Keycloak integration is not yet implemented.
> The gateway is configured for JWT validation against an authorization server, but you will need to wire in Keycloak adapters or point to a Keycloak realm/JWK URI once the setup is ready.

## Adding New Routes

To expose a new service endpoint via the gateway:

1. **Define the route** in `application.yml` under `spring.cloud.gateway.routes`:

   ```yaml
   - id: order-service
     uri: lb://mankind-order-service
     predicates:
       - Path=/api/v1/orders/**
     filters:
       - StripPrefix=1
   ```
2. **Restart** the gateway to pick up changes.
3. Ensure the downstream service is registered in your discovery mechanism (e.g., Eureka).

No additional code changes are needed in the gateway for simple routing.

### Adding Swagger Documentation

To enable Swagger documentation access through the gateway for a new service, add these additional routes:

```yaml
# API Documentation (OpenAPI JSON)
- id: order-api-docs-root
  uri: http://localhost:8084
  predicates:
    - Path=/order-api-docs
  filters:
    - SetPath=/v3/api-docs

- id: order-api-docs
  uri: http://localhost:8084
  predicates:
    - Path=/order-api-docs/**
  filters:
    - RewritePath=/order-api-docs/(?<segment>.*), /v3/api-docs/${segment}

# Swagger UI
- id: order-swagger-ui-root
  uri: http://localhost:8084
  predicates:
    - Path=/docs/orders
  filters:
    - SetPath=/swagger-ui/index.html

- id: order-swagger-ui-static
  uri: http://localhost:8084
  predicates:
    - Path=/docs/orders/**
  filters:
    - RewritePath=/docs/orders/(?<segment>.*), /swagger-ui/${segment}
```

### Available Swagger Documentation URLs

#### Swagger UI Access
- **Product Service:** `http://localhost:8085/docs/products`
- **Cart Service:** `http://localhost:8085/docs/cart`
- **User Service:** `http://localhost:8085/docs/users`
- **Wishlist Service:** `http://localhost:8085/docs/wishlist`

#### API Documentation (OpenAPI JSON)
- **Product Service:** `http://localhost:8085/product-api-docs`
- **Cart Service:** `http://localhost:8085/cart-api-docs`
- **User Service:** `http://localhost:8085/user-api-docs`
- **Wishlist Service:** `http://localhost:8085/wishlist-api-docs`
