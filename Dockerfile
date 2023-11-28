FROM openjdk:11-jdk AS builder
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
COPY src src
RUN chmod +x ./gradlew
RUN ./gradlew bootJar
FROM openjdk:17-alpine
COPY --from=builder build/libs/*.jar msa-discovery.jar
VOLUME /tmp
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=prod","msa-discovery.jar"]