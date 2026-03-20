# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build

# Copy the entire project
COPY . .

# First, build and install API dependencies
RUN mvn clean install -pl user-api,product-api -am -DskipTests

# Now build the notification-service
RUN cd notification-service && \
    mvn clean package spring-boot:repackage -DskipTests && \
    ls -la target/

# Run stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from build stage
COPY --from=build /build/notification-service/target/*.jar app.jar

# Set environment variables
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Expose the application port (make sure it matches server.port in application.yml)
EXPOSE 8086

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
