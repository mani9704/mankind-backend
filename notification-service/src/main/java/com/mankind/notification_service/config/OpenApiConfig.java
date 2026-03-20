package com.mankind.notification_service.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI notificationServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Mankind Matrix Notification Service API")
                        .description("""
                            API documentation for the Mankind Matrix Notification Service.
                            This service provides endpoints for managing notifications, allowing users to:
                            - Send email notifications
                            - Send SMS notifications
                            - Manage notification preferences
                            - Track notification delivery

                            All endpoints are prefixed with `/notifications`.
                            
                            Swagger UI: http://localhost:8086/swagger-ui
                            """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Mankind Matrix Team")
                                .email("support@mankindmatrix.com")
                                .url("https://www.mankindmatrix.com"))
                        .license(new License()
                                .name("Proprietary")
                                .url("https://www.mankindmatrix.com/license")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8086")
                                .description("Local Development Server (Direct Access)"),
                        new Server()
                                .url("http://localhost:8085/api/v1/notifications")
                                .description("Gateway Server (Through Gateway)")
                ));
    }
}