FROM maven:3.8.1-jdk-8-slim as builder

# Copy local code to the container image.
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build a release artifact.
RUN mvn package -DskipTests

# Copy the built jar to a stable name so version bumps don't break the CMD.
RUN cp target/*.jar app.jar

# Run the web service on container startup.
CMD ["java","-jar","/app/app.jar","--spring.profiles.active=prod"]