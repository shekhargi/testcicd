FROM adoptopenjdk/openjdk11:latest
ARG TEST_ENV_VAR
ENV TEST_ENV_VAR=${TEST_ENV_VAR}
EXPOSE 8080
RUN echo $TEST_ENV_VAR
ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
COPY ./ $APP_HOME
RUN chmod -R 755 ./gradlew
RUN ./gradlew clean build
ENV JAR_FILE=build/libs/spring-boot-cicd-test-0.0.1-SNAPSHOT.jar
RUN mv ${JAR_FILE} app.jar
CMD ["java","-jar","app.jar"]


