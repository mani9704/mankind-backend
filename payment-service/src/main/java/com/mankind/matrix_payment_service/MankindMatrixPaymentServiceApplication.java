package com.mankind.matrix_payment_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;

@SpringBootApplication
@OpenAPIDefinition(
    info = @Info(
        title = "Payment Service API",
        version = "1.0.0",
        description = "API documentation for the Mankind Matrix Payment Service"
    )
)
public class MankindMatrixPaymentServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MankindMatrixPaymentServiceApplication.class, args);
    }

}