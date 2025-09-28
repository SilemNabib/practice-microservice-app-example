# ======================
# Stage 1: build
# ======================

FROM maven:3.8.6-openjdk-8-slim AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# ======================
# Stage 2: runtime
# ======================

FROM maven:3.8.6-openjdk-8-slim

WORKDIR /app

COPY --from=build /app/target/users-api-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8083

# Default env values
ENV JWT_SECRET=PRFT
ENV SERVER_PORT=8083

ENTRYPOINT ["java", "-jar", "app.jar"]