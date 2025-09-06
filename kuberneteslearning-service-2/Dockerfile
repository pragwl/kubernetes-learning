# ----------------------------
# Stage 1: Build
# ----------------------------
FROM gradle:jdk21 AS builder

WORKDIR /app

COPY gradle/ gradle/
COPY build.gradle settings.gradle ./
COPY src/ src/

RUN gradle clean bootJar --no-daemon

# ----------------------------
# Stage 2: Run
# ----------------------------
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
