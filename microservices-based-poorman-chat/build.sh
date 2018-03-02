#!/usr/bin/env bash

# Buidling uniqueid
cd uniqueid
mvn package
docker build . -t uniqueid-service
cd --
