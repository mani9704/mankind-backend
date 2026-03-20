package com.mankind.mankindmatrixuserservice.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.ExternalDocumentation;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "bearerAuth";

    @Bean
    public OpenAPI userServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Mankind Matrix User Service API")
                        .description("""
                                # Mankind Matrix User Service API
                                
                                ## Overview
                                This API provides comprehensive user management functionality for the Mankind Matrix platform, 
                                including user registration, authentication, profile management, and address management.
                                
                                ## Authentication
                                This service uses **Keycloak** for authentication and authorization. All protected endpoints 
                                require a valid JWT token obtained from Keycloak.
                                
                                ## Getting Started
                                
                                1. **Register a user**: Use the `/auth/register` endpoint
                                2. **Login**: Use the `/auth/login` endpoint to get a JWT token
                                3. **Access protected endpoints**: Include the JWT token in the Authorization header
                                4. **Manage profile**: Use the `/users/me/**` endpoints for self-service
                                5. **Admin operations**: Use the `/users/**` endpoints (requires ADMIN role)
                                
                                ## Security
                                - JWT tokens are validated by Keycloak
                                - Users can only access their own data
                                - Admin endpoints require ADMIN role
                                - All tokens have expiration times
                                
                                ## Error Handling
                                - **401 Unauthorized**: Invalid or missing JWT token
                                - **403 Forbidden**: Insufficient permissions
                                - **404 Not Found**: Resource not found
                                - **409 Conflict**: Data conflict (e.g., email already exists)
                                """)
                        .version("2.0.0")
                        .contact(new Contact()
                                .name("Mankind Matrix Team")
                                .email("support@mankindmatrix.com")
                                .url("https://www.mankindmatrix.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8081")
                                .description("Local Development Server (Direct Access)"),
                        new Server()
                                .url("http://localhost:8085/api/v1")
                                .description("Gateway Server (Through Gateway - Recommended)")
                ))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("""
                                        ## JWT Token Authentication
                                        
                                        ### How to get a token:
                                        1. Register a user: `POST /auth/register`
                                        2. Login: `POST /auth/login`
                                        3. Use the `access_token` from the response
                                        
                                        ### How to use the token:
                                        Include the token in the Authorization header:
                                        ```
                                        Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
                                        ```
                                        
                                        ### Token Information:
                                        - **Issuer**: Keycloak (http://localhost:8180/realms/mankind)
                                        - **Type**: JWT (JSON Web Token)
                                        - **Format**: Bearer token
                                        - **Expiration**: Configurable in Keycloak
                                        
                                        ### Example:
                                        ```bash
                                        curl -X GET http://localhost:8085/api/v1/users/me \\
                                          -H "Authorization: Bearer YOUR_JWT_TOKEN"
                                        ```
                                        """)))
                .externalDocs(new ExternalDocumentation()
                        .description("Mankind Matrix Documentation")
                        .url("https://docs.mankindmatrix.com"));
    }
}