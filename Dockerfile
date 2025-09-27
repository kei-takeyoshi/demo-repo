# Dockerfile
# --- Build stage ---
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# 依存を先取りしてキャッシュ効かせる
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests package

# --- Runtime stage ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# repackage 済みの fat-jar を app.jar として配置（ワイルドカードで拾う）
COPY --from=builder /app/target/*-SNAPSHOT.jar /app/app.jar

EXPOSE 8080
# ここで -jar 実行。Main-Class は repackage 済みJARに含まれる
ENTRYPOINT ["java","-jar","/app/app.jar"]
