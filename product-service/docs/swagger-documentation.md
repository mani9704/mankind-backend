# Swagger Documentation Guide for Product API

## Overview
This document provides guidelines for using Swagger/OpenAPI to document the Product API in the Mankind Matrix Product Service. Swagger provides interactive documentation that allows developers to understand and test the API directly from a web interface.

## Accessing Swagger UI
The Swagger UI for the Product API is available at:
```
http://localhost:8080/swagger-ui.html
```

## OpenAPI Specification
The OpenAPI specification (in JSON format) is available at:
```
http://localhost:8080/v3/api-docs
```

## Swagger Configuration
The Swagger configuration is defined in the `OpenApiConfig` class. This configuration includes:
- API information (title, description, version)
- Contact information
- License information
- Security schemes

## Documenting Controllers
Controllers are documented using OpenAPI annotations:

```java
@RestController
@RequestMapping("/api/products")
@Tag(name = "Product Controller", description = "API for product management")
public class ProductController {

    @Operation(
        summary = "Get all products",
        description = "Retrieves a paginated list of all products",
        responses = {
            @ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved products",
                content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = Page.class)
                )
            ),
            @ApiResponse(
                responseCode = "401",
                description = "Unauthorized",
                content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = ErrorResponse.class)
                )
            )
        }
    )
    @GetMapping
    public Page<ProductDTO> getAllProducts(Pageable pageable) {
        // Implementation
    }
}
```

## Documenting Models
Models are documented using OpenAPI annotations:

```java
@Schema(description = "Product Data Transfer Object")
public class ProductDTO {

    @Schema(description = "Unique identifier of the product", example = "1")
    private Long id;

    @Schema(description = "Name of the product", example = "Smartphone X")
    private String name;

    @Schema(description = "Detailed description of the product", example = "Latest smartphone with advanced features")
    private String description;

    @Schema(description = "Price of the product", example = "999.99")
    private BigDecimal price;

    @Schema(description = "Category of the product", example = "Electronics")
    private String category;

    @Schema(description = "Indicates if the product is in stock", example = "true")
    private Boolean inStock;

    // Getters and setters
}
```

## Best Practices for Swagger Documentation

1. **Be Comprehensive**: Document all endpoints, parameters, and responses
2. **Include Examples**: Provide example values for all fields
3. **Document Error Responses**: Include all possible error responses
4. **Use Descriptive Summaries**: Write clear, concise summaries for operations
5. **Group Related Endpoints**: Use tags to group related endpoints
6. **Document Security Requirements**: Specify authentication requirements
7. **Keep Documentation Updated**: Update Swagger docs when API changes

## Common Annotations

- `@Tag`: Groups operations by resource or functionality
- `@Operation`: Describes an API operation
- `@Parameter`: Documents an operation parameter
- `@ApiResponse`: Documents a response for an operation
- `@Schema`: Documents a model or model property
- `@SecurityRequirement`: Specifies security requirements

## Testing with Swagger UI

1. Navigate to the Swagger UI URL
2. Browse the available endpoints
3. Click on an endpoint to expand it
4. View the documentation and parameters
5. Click "Try it out" to test the endpoint
6. Enter required parameters
7. Click "Execute" to send the request
8. View the response