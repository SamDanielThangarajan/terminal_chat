#!/usr/bin/env bash

# Buidling uniqueid
cd uniqueid
mvn package
docker build . -t uniqueid-service
cd ..

# Build registry
cd registry/registry
mvn package
docker build . -t registry-service
cd ../..
