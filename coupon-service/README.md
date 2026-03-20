# Coupon Service

This is the Coupon microservice for the Mankind Matrix AI platform. It handles coupon management, validation, and usage tracking.

## Features

- **Coupon Management**: Create, update, and manage discount coupons
- **Validation Engine**: Validate coupon codes for users
- **Usage Tracking**: Track coupon usage per user and globally
- **Business Rules**: Support for various coupon types and restrictions

## API Endpoints

### Health Check
- `GET /coupons/health` - Service health check

### Public Endpoints
- `GET /coupons/public` - Get all active public coupons
- `POST /coupons/validate` - Validate a coupon code for a user

### Admin Endpoints
- `GET /coupons` - Get all coupons (paginated)
- `GET /coupons/{id}` - Get coupon by ID

## Coupon Types

- **PERCENTAGE**: Percentage discount (e.g., 10% off)
- **FIXED_AMOUNT**: Fixed amount discount (e.g., $5 off)
- **FREE_SHIPPING**: Free shipping discount

## Business Rules

- **Expiration**: Coupons have start and end dates
- **Usage Limits**: Global and per-user usage limits
- **Minimum Order**: Minimum order amount requirements
- **User Restrictions**: New users only, specific user restrictions
- **Product/Category Restrictions**: Applicable to specific products or categories

## Database Schema

### Coupons Table
- `id`: Primary key
- `code`: Unique coupon code
- `name`: Coupon name
- `description`: Coupon description
- `type`: Coupon type (PERCENTAGE, FIXED_AMOUNT, FREE_SHIPPING)
- `value`: Discount value
- `minimumOrderAmount`: Minimum order amount required
- `maxUsage`: Maximum global usage
- `currentUsage`: Current usage count
- `validFrom`: Start date
- `validTo`: End date
- `isActive`: Whether coupon is active
- `isPublic`: Whether coupon is publicly available
- `applicableCategories`: JSON string of category IDs
- `applicableProducts`: JSON string of product IDs
- `restrictedUsers`: JSON string of restricted user IDs
- `newUsersOnly`: Whether only new users can use
- `oneTimeUsePerUser`: Whether one-time use per user
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

### Coupon Usage Table
- `id`: Primary key
- `coupon_id`: Foreign key to coupons table
- `user_id`: User ID
- `order_id`: Order ID
- `used_at`: Usage timestamp
- `created_at`: Creation timestamp

## Running the Service

### Local Development
```bash
cd coupon-service
./mvnw spring-boot:run
```

### Docker
```bash
docker-compose up coupon-service
```

## Swagger Documentation

Once the service is running, you can access the Swagger UI at:
- Local: http://localhost:8087/swagger-ui
- Gateway: http://localhost:8085/api/v1/coupons/swagger-ui

## Configuration

The service uses the following environment variables:
- `DB_HOST`: Database host
- `DB_PORT`: Database port
- `DB_NAME`: Database name
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password
- `KEYCLOAK_URL`: Keycloak server URL 