# --- Build stage ---
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Pre-fetch dependencies to leverage layer cache
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests package

# --- Runtime stage ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the repackage'd Spring Boot fat-jar as app.jar
COPY --from=builder /app/target/*-SNAPSHOT.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
