# Notification Service

This service provides notification capabilities for the Mankind Matrix AI platform.

## Features

- Send email notifications to users
- Support for different notification types (currently only EMAIL is implemented)
- Validation of notification requests
- Error handling for failed notifications

## API Endpoints

### Send Notification

Sends a notification to a user.

**URL**: `/api/notifications/send`

**Method**: `POST`

**Request Body**:
```json
{
  "userEmail": "user@example.com",
  "subject": "Notification Subject",
  "message": "Notification message content",
  "type": "EMAIL"
}
```

**Response**:
- `200 OK`: Notification sent successfully
- `400 Bad Request`: Invalid request (with validation errors)
- `500 Internal Server Error`: Failed to send notification

## Configuration

Email configuration is set in `application.yml`:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${MAIL_USERNAME:your-email@gmail.com}
    password: ${MAIL_PASSWORD:your-app-password}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
            required: true
```

For Gmail, you need to:
1. Enable 2-Step Verification for your Google account
2. Generate an App Password
3. Use that App Password in the configuration

## Environment Variables

- `MAIL_USERNAME`: Email address to send notifications from
- `MAIL_PASSWORD`: Password or app password for the email account

## Running the Service

### Local Development

```bash
cd notification-service
./mvnw spring-boot:run
```

### Docker

```bash
docker-compose up notification-service
```

## Swagger Documentation

Swagger UI is available at: `http://localhost:8085/swagger-ui/index.html`
