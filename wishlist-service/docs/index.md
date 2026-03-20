# Wishlist Service Documentation

Welcome to the Wishlist Service documentation. This documentation provides comprehensive information about the Wishlist Service, a microservice component of the Mankind Matrix backend system.

## Documentation Index

### Overview and Getting Started
- [README](README.md) - Overview, setup instructions, and general information

### API Documentation
- [API Documentation](API-DOCUMENTATION.md) - Detailed API endpoint documentation

### Technical Documentation
- [Technical Architecture](TECHNICAL-ARCHITECTURE.md) - Detailed technical architecture and design

## Quick Links

### API Endpoints
- `POST /api/wishlist` - Add item to wishlist
- `GET /api/wishlist/{userId}` - Get user's wishlist
- `DELETE /api/wishlist` - Remove item from wishlist
- `GET /api/wishlist/check` - Check if item is in wishlist

### Swagger UI
When the service is running, you can access the interactive API documentation at:
```
http://localhost:8082/swagger-ui.html
```

### Example Requests
Example API requests can be found in the [api/requests.http](../api/requests.http) file.

## Service Information

- **Service Name**: matrix-wishlist-service
- **Port**: 8082
- **Database**: MySQL (wishlistdb)
- **Java Version**: 17
- **Spring Boot Version**: 3.2.5

## Getting Started

To get started with the Wishlist Service:

1. Review the [README](README.md) for an overview and setup instructions
2. Explore the [API Documentation](API-DOCUMENTATION.md) to understand the available endpoints
3. If you need to understand the technical implementation, refer to the [Technical Architecture](TECHNICAL-ARCHITECTURE.md)

## Contributing to Documentation

When contributing to this documentation, please follow these guidelines:

1. Use Markdown format for all documentation files
2. Keep the documentation up-to-date with code changes
3. Include examples where appropriate
4. Maintain a consistent style across all documentation files