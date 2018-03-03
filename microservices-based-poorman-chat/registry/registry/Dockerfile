FROM java:8
WORKDIR /
ADD target/registry-0.0.1-SNAPSHOT-spring-boot.jar registry-0.0.1-SNAPSHOT-spring-boot.jar
EXPOSE 6000
CMD java -jar registry-0.0.1-SNAPSHOT-spring-boot.jar port=6000 protocol=grpc
