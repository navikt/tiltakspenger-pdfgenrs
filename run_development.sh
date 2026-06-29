#!/bin/bash

CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CONTAINER_NAME="tiltakspenger-pdfgenrs"

docker build -t "$CONTAINER_NAME" "$CURRENT_PATH"

docker run \
        --name "$CONTAINER_NAME" \
        -v $CURRENT_PATH/templates:/app/templates \
        -v $CURRENT_PATH/fonts:/app/fonts \
        -v $CURRENT_PATH/data:/app/data \
        -v $CURRENT_PATH/resources:/app/resources \
        -p 8085:8080 \
        -e DEV_MODE=true \
        -e JDK_JAVA_OPTIONS \
        -it \
        --rm \
        "$CONTAINER_NAME"