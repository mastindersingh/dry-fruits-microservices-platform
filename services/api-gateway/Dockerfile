FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Create runtime image
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy built jar
COPY --from=0 /app/target/*.jar app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
