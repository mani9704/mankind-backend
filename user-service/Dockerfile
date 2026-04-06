# Build with the monorepo root as the Docker context:
# docker build -f user-service/Dockerfile -t mankind-user-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY . .

RUN mvn -B clean install -pl user-api -am -DskipTests
RUN cd user-service && mvn -B clean package spring-boot:repackage -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app

ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"

COPY --from=build /workspace/user-service/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
