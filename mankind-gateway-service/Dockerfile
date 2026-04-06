# Build with the monorepo root as the Docker context:
# docker build -f mankind-gateway-service/Dockerfile -t mankind-gateway-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY . .

RUN cd mankind-gateway-service && mvn -B clean package spring-boot:repackage -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app

ENV JAVA_OPTS="-Xms256m -Xmx512m"

COPY --from=build /workspace/mankind-gateway-service/target/*.jar app.jar

EXPOSE 8085

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
