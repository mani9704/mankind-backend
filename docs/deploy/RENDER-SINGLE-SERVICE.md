# Render Single-Service Deployment

This repository now supports a single Render web service that starts:

- Keycloak
- `user-service`
- `product-service`
- `cart-service`
- `wishlist-service`
- `payment-service`
- `notification-service`
- `coupon-service`
- `order-service`
- `mankind-gateway-service`

Only the gateway is exposed publicly through Render. All other services stay internal inside the same container.

## Render settings

- Dockerfile path: `Dockerfile.render`
- Docker build context: `.`
- Health check path: `/actuator/health`

## Required environment variables

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USERNAME`
- `DB_PASSWORD`

## Recommended environment variables

- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`
- `APP_CORS_ALLOWED_ORIGIN_PATTERNS`
- `MAIL_USERNAME`
- `MAIL_PASSWORD`
- `STRIPE_SECRET_KEY`
- `STRIPE_API_KEY`
- `STRIPE_PUBLIC_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `SMS_ACCOUNT_SID`
- `SMS_AUTH_TOKEN`
- `SMS_PHONE_NUMBER`

## Vercel frontend

Set Vercel `REACT_APP_API_URL` to your Render backend URL.

Examples:

- `https://your-backend.onrender.com`
- `https://your-backend.onrender.com/api/v1`

The frontend gateway-aware API config will normalize both forms.
