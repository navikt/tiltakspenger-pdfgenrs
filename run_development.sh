#!/bin/bash

CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CONTAINER_NAME="tiltakspenger-pdfgenrs"

# Upstream-imaget publiseres kun for linux/amd64; eksplisitt platform for arm64-maskiner.
docker build --platform linux/amd64 -t "$CONTAINER_NAME" "$CURRENT_PATH"

docker run \
        --platform linux/amd64 \
        --name "$CONTAINER_NAME" \
        -v $CURRENT_PATH/templates:/app/templates \
        -v $CURRENT_PATH/fonts:/app/fonts \
        -v $CURRENT_PATH/data:/app/data \
        -v $CURRENT_PATH/resources:/app/resources \
        -v $CURRENT_PATH/lib:/app/lib \
        -p 8084:8080 \
        -e DEV_MODE=true \
        -it \
        --rm \
        "$CONTAINER_NAME"
