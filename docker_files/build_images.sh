#/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SRC_DIR=${SCRIPT_PATH}/../tcs-src

uid=$(id -u ${USER})

echo "Building image for unique id service..."
cd ${SRC_DIR}/unique_id && docker build -t uniqueid_service --build-arg USER=${USER} --build-arg UID=${uid} .-build-arg UID=${uid} .
echo "Building image for unique id service...done"

echo "Building image for registry service..."
cd ${SRC_DIR}/registry/ && docker build -t registry_service --build-arg USER=${USER} --build-arg UID=${uid} .
echo "Building image for registry service...done"

echo "Building image for messaging service..."
cd ${SRC_DIR}/messaging/ && docker build -t messaging_service --build-arg USER=${USER} --build-arg UID=${uid} .
echo "Building image for messaging service...done"

echo "Building image for gc service..."
cd ${SRC_DIR}/garbage_collector/ && docker build -t gc_service --build-arg USER=${USER} --build-arg UID=${uid} .
echo "Building image for gc service...done"
