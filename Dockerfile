FROM maven:3.9-eclipse-temurin-17 AS build

ARG SERVICE_NAME=product-service
ARG BUILD_MODULES=user-api,product-api,payment-api,coupon-api

WORKDIR /build
COPY . .

# Build shared API modules first so dependent services can resolve them
RUN mvn clean install -pl ${BUILD_MODULES} -am -DskipTests

# Build the selected service and create a runnable jar
RUN cd /build/${SERVICE_NAME} && \
	mvn clean package spring-boot:repackage -DskipTests && \
	ls -la target/

FROM eclipse-temurin:17-jre

ARG SERVICE_NAME=product-service
ARG SERVICE_PORT=8080

WORKDIR /app
COPY --from=build /build/${SERVICE_NAME}/target/*.jar app.jar

ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:MaxMetaspaceSize=256m"

EXPOSE ${SERVICE_PORT}
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]