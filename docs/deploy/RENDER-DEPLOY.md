# Deploying Mankind Backend to Render.com (Simple Guide)

## 1. Prerequisites
- You have a [Render.com](https://render.com) account.
- Your database is already set up and connection details are in your `.env` file.
- Each service has its own Dockerfile.

## 2. Deploy Each Service

For each microservice (`user-service`, `product-service`, `cart-service`, `wishlist-service`):

1. Go to the Render Dashboard and click "New +" → "Web Service".
2. Connect your GitHub repository.
3. Set these options:
   - **Dockerfile Path:** `service-name/Dockerfile` (e.g., `product-service/Dockerfile`)
   - **Docker Build Context Directory:** `.`
   - **Docker Command:** (leave blank)
4. Add environment variables from your `.env` file (DB connection, JWT secret, etc).
5. Click "Create Web Service".

## 3. After Deploying

- Render will build and start your service.
- Visit the provided URL to test your API.
- Check logs in the Render dashboard for errors.

## Health Checks

Render automatically performs health checks. Ensure each service has a health endpoint:

```java
@RestController
public class HealthController {
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("UP");
    }
}
```

## Auto-Deploy Configuration

Render automatically deploys when you push to the configured branch. Configure auto-deploy:

1. Go to service settings
2. Under "Auto-Deploy":
   - Enable for main branch
   - Enable for pull requests (optional)
   - Set up preview environments (optional)

