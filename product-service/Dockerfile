# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build

# Copy the entire project
COPY . .

# First, build and install the API modules to local repository
RUN mvn clean install -pl user-api,product-api -am -DskipTests

# Then build the product service
RUN cd product-service && \
    mvn clean package spring-boot:repackage -DskipTests && \
    ls -la target/

# Run stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from build stage
COPY --from=build /build/product-service/target/*.jar app.jar

# Set environment variables
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 