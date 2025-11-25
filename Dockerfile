FROM eclipse-temurin:17-jre
COPY target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
