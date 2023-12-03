FROM openjdk:11-jdk AS builder
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
COPY src src
COPY elastic-apm-agent-1.44.0.jar .
RUN chmod +x ./gradlew
RUN ./gradlew bootJar
FROM openjdk:11-slim
COPY --from=builder build/libs/*.jar msa-discovery.jar
COPY --from=builder elastic-apm-agent-1.44.0.jar .
VOLUME /tmp
ENV JAVA_TOOL_OPTIONS="-javaagent:/elastic-apm-agent-1.44.0.jar"
ENTRYPOINT ["java",
 "-Dspring.profiles.active=prod",
 "-Delastic.apm.service_name=msa-discovery",
 "-Delastic.apm.secret_token=hyUExzAkUlugz8LsPW",
 "-Delastic.apm.server_url=https://f694429f0917434384e0abfab751507d.apm.us-west-2.aws.cloud.es.io:443",
 "-Delastic.apm.environment=msa-discovery-enviroment",
 "-Delastic.apm.application_packages=com.allways",
 "-jar", "msa-discovery.jar"]