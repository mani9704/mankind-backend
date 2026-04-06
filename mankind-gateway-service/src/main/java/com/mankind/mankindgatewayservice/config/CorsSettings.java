package com.mankind.mankindgatewayservice.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class CorsSettings {

    private final List<String> allowedOriginPatterns;

    public CorsSettings(
            @Value("${app.cors.allowed-origin-patterns:http://localhost:3000,http://127.0.0.1:3000,http://localhost:8085,http://127.0.0.1:8085,https://*.vercel.app,https://*.onrender.com}") String allowedOriginPatterns
    ) {
        this.allowedOriginPatterns = Arrays.stream(allowedOriginPatterns.split(","))
                .map(String::trim)
                .filter(origin -> !origin.isEmpty())
                .toList();
    }

    public List<String> getAllowedOriginPatterns() {
        return allowedOriginPatterns;
    }
}
