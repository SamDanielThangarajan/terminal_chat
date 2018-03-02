FROM java:8
WORKDIR /
ADD target/uniqueid-0.0.1-SNAPSHOT-spring-boot.jar uniqueid-0.0.1-SNAPSHOT-spring-boot.jar
EXPOSE 5000
CMD java -jar uniqueid-0.0.1-SNAPSHOT-spring-boot.jar port=5000 protocol=grpc
