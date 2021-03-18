#!/bin/bash

set -eu

IMAGE=testimage
DOCKER_CONF=Dockerfile

docker build --no-cache \
    --tag "${IMAGE}" \
    -f ${DOCKER_CONF} .

docker run -dit --name containertest -p 8080:80 ${IMAGE}
