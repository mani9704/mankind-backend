package com.mankind.mankindgatewayservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.web.cors.CorsConfiguration;

import java.util.Arrays;

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    private final CorsSettings corsSettings;

    public SecurityConfig(CorsSettings corsSettings) {
        this.corsSettings = corsSettings;
    }

    @Bean
    SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(request -> {
                    CorsConfiguration config = new CorsConfiguration();
                    config.setAllowedOriginPatterns(corsSettings.getAllowedOriginPatterns());
                    config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
                    config.setAllowedHeaders(Arrays.asList("*"));
                    config.setAllowCredentials(true);
                    config.setMaxAge(3600L);
                    return config;
                }))
                .authorizeExchange(ex -> ex
                        // Public endpoints (no authentication required)
                        .pathMatchers("/", "/index.html").permitAll()
                        .pathMatchers("/actuator/**").permitAll()  // Allow public access to actuator endpoints
                        .pathMatchers("/api/v1/auth/**").permitAll()
                        
                        // User profile endpoints (require authentication)
                        .pathMatchers("/api/v1/users/me/**").authenticated()
                        
                        // Product service - public read access, protected write access
                        .pathMatchers(HttpMethod.GET, "/api/v1/products", "/api/v1/products/**").permitAll()
                        .pathMatchers(HttpMethod.GET, "/api/v1/categories", "/api/v1/categories/**").permitAll()
                        .pathMatchers(HttpMethod.GET, "/api/v1/reviews/**").permitAll()
                        .pathMatchers(HttpMethod.GET, "/api/v1/inventory/**").permitAll()
                        
                        // Protected product endpoints (require authentication for write operations)
                        .pathMatchers(HttpMethod.POST, "/api/v1/products", "/api/v1/products/**").authenticated()
                        .pathMatchers(HttpMethod.PUT, "/api/v1/products/**").authenticated()
                        .pathMatchers(HttpMethod.DELETE, "/api/v1/products/**").authenticated()
                        .pathMatchers(HttpMethod.PATCH, "/api/v1/products/**").authenticated()
                        .pathMatchers(HttpMethod.POST, "/api/v1/categories", "/api/v1/categories/**").authenticated()
                        .pathMatchers(HttpMethod.PUT, "/api/v1/categories/**").authenticated()
                        .pathMatchers(HttpMethod.DELETE, "/api/v1/categories/**").authenticated()
                        .pathMatchers(HttpMethod.POST, "/api/v1/reviews", "/api/v1/reviews/**").authenticated()
                        .pathMatchers(HttpMethod.PUT, "/api/v1/reviews/**").authenticated()
                        .pathMatchers(HttpMethod.DELETE, "/api/v1/reviews/**").authenticated()
                        .pathMatchers(HttpMethod.POST, "/api/v1/inventory", "/api/v1/inventory/**").authenticated()
                        .pathMatchers(HttpMethod.PUT, "/api/v1/inventory/**").authenticated()
                        
                        // Protected endpoints (authentication required)
                        .pathMatchers("/api/v1/users/**").authenticated()  // Admin endpoints - just require authentication
                        .pathMatchers("/api/v1/cart/**").authenticated()
                        .pathMatchers("/api/v1/wishlist/**").authenticated()
                        .pathMatchers("/api/v1/payments/**").authenticated()
                        .pathMatchers("/api/v1/admin/payments/**").authenticated()
                        .pathMatchers("/api/v1/notifications/**").authenticated()
                        .pathMatchers("/api/v1/coupons/**").authenticated()  // Coupon service requires authentication
                        .pathMatchers("/api/v1/orders/**").authenticated()  // Order service requires authentication
                        .pathMatchers("/api/v1/recently-viewed/**").authenticated()
                        .pathMatchers("/api/v1/suppliers/**").authenticated()
                        
                        // Default: require authentication for any other endpoints
                        .anyExchange().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        return http.build();
    }
}
