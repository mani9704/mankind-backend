# Mankind Matrix User Service

A microservice for managing users, including registration, login, and basic user details. Uses MySQL as the database.


## Service

### `user-service/`
- Handles user registration, login, and authentication
- Secured using JWT (JSON Web Tokens)
- Role-based access control
- Centralized exception handling and error responses

## Test Endpoints

Use Postman or your browser (for GETs):

#### ✅ Register a User

```http
POST http://localhost:8081/api/v1/auth/register
Content-Type: application/json

{
  "username": "jane_doe",
  "email": "jane@example.com",
  "firstName": "Jane",
  "lastName": "Doe",
  "password": "password123"
}
```

#### ✅ Login User

```http
POST http://localhost:8081/api/v1/auth/login
Content-Type: application/json

{
  "username": "jane_doe",
  "password": "password123"
}
```

#### ✅ Get All Users

```http
GET http://localhost:8081/api/v1/users
Accept: application/json
```

#### ✅ Get User by ID

```http
GET http://localhost:8081/api/v1/users/1
Accept: application/json
```


