# Multi-Module API & Feign Pattern Guide

This document shows how we’ve structured `user-api` & `product-api` modules, wired them into services with Feign clients, and how you can apply the same steps to any **new service** you add.

---

## 1. Why this pattern?

- **Separation of Concerns**
    - `*-api` modules hold *only* DTOs, enums, validation annotations, and (optionally) OpenAPI specs.
    - Service modules contain business logic, persistence, Feign clients, and controllers.

- **Loose Coupling**
    - Consumers depend on a stable *contract* JAR, not internal entities.
    - Breaking changes to persistence layer don’t ripple to clients.

- **Secure Service to Service**
    - Feign + header-propagating interceptor ensures JWTs flow between services without opening endpoints to anonymous traffic.

- **Ease of Onboarding**
    - New services simply add the matching `*-api` and Feign client; no manual DTO copying.

---

## 2. Project Layout

```
mankind-backend/
├── pom.xml
├── user-api/
├── product-api/
├── user-service/
├── product-service/
├── cart-service/
├── wishlist-service/
└── api-gateway/
```

---

## 3. Extract DTOs into `*-api` Modules

1. Create module structure:
   ```bash
   mkdir -p new-api/src/main/java/com/mankind/api/new
   mkdir -p new-api/src/main/resources
   ```
2. Minimal `new-api/pom.xml`:
   ```xml
   <project>
     <parent>
       <groupId>com.mankind</groupId>
       <artifactId>mankind-backend</artifactId>
       <version>${project.version}</version>
     </parent>
     <artifactId>new-api</artifactId>
     <packaging>jar</packaging>
     <dependencies>
       <dependency>
         <groupId>com.fasterxml.jackson.core</groupId>
         <artifactId>jackson-databind</artifactId>
       </dependency>
       <dependency>
         <groupId>jakarta.validation</groupId>
         <artifactId>jakarta.validation-api</artifactId>
       </dependency>
       <dependency>
         <groupId>org.projectlombok</groupId>
         <artifactId>lombok</artifactId>
         <scope>provided</scope>
       </dependency>
     </dependencies>
   </project>
   ```
3. Move DTOs & enums into `new-api`; update packages to `com.mankind.api.new`.
4. Build to verify:
   ```bash
   mvn clean install -pl new-api
   ```

---

## 4. Wire Service Module to the `*-api`

1. Add dependency in `new-service/pom.xml`:
   ```xml
   <dependency>
     <groupId>com.mankind</groupId>
     <artifactId>new-api</artifactId>
   </dependency>
   ```
2. Remove old DTO folder from `new-service`.
3. Import shared types:
   ```java
   import com.mankind.api.new.YourDTO;
   ```
4. Rebuild:
   ```bash
   mvn clean install -pl new-service
   ```

---

## 5. Add Feign Client for Service to Service Calls

### A. Configure External Service URL
In `new-service/src/main/resources/application.yml`:
```yaml
peer-service:
  url: http://localhost:8081
```

### B. Add Feign dependencies
In `new-service/pom.xml`:
```xml
<dependencyManagement>
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-dependencies</artifactId>
    <version>${springframework.cloud.version}</version>
    <type>pom</type>
    <scope>import</scope>
  </dependency>
</dependencyManagement>
<dependencies>
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
  </dependency>
  <dependency>
    <groupId>com.mankind</groupId>
    <artifactId>peer-api</artifactId>
  </dependency>
</dependencies>
```

### C. FeignConfig for Header Propagation
```java
package com.mankind.newservice.config;

import feign.RequestInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignConfig {
    @Bean
    public RequestInterceptor propagateAuthToken() {
        return template -> {
            ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest req = attrs.getRequest();
                String auth = req.getHeader(HttpHeaders.AUTHORIZATION);
                if (StringUtils.hasText(auth)) {
                    template.header(HttpHeaders.AUTHORIZATION, auth);
                }
            }
        };
    }
}
```

### D. Feign Client Interface
```java
package com.mankind.newservice.client;

import com.mankind.api.peer.PeerDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(
  name = "peer-service",
  url = "${peer-service.url}",
  configuration = com.mankind.newservice.config.FeignConfig.class
)
public interface PeerClient {
    @GetMapping("/api/v1/peers/{id}")
    PeerDTO getPeerById(@PathVariable Long id);
    @GetMapping("/api/v1/peers")
    List<PeerDTO> getAllPeers();
}
```

### E. Enable Feign in Main App
```java
@SpringBootApplication
@EnableFeignClients(basePackages = "com.mankind.newservice")
public class NewServiceApplication { … }
```

### F. Use in Controller
```java
@RestController
public class TestController {
  private final PeerClient peerClient;
  public TestController(PeerClient peerClient) {
    this.peerClient = peerClient;
  }
  @GetMapping("/api/test/peer/{id}")
  public PeerDTO getPeer(@PathVariable Long id) {
    return peerClient.getPeerById(id);
  }
}
```

---

## 6. Security Config in Auth Service
```java
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
  http
    .csrf().disable()
    .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
    .authorizeHttpRequests(auth -> auth
      .requestMatchers("/api/v1/auth/**").permitAll()
      .anyRequest().authenticated()
    )
    .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
  return http.build();
}
```

---

## 7. Testing & Next Steps

1. Start peer-service (auth) on port 8081.
2. Login to get JWT:
   ```bash
   curl -X POST http://localhost:8081/api/v1/auth/login      -d '{"username":"user","password":"pass"}'
   ```  
3. Start new-service on port 8082 and call test endpoint:
   ```bash
   curl http://localhost:8082/api/test/peer/1      -H "Authorization: Bearer <token>"
   ```
4. Future: replace static URLs with Eureka; add API Gateway; circuit breakers; refresh-token flow.
