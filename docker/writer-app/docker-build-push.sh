#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


REGISTRY_HOST="registry-server.taild476f.ts.net"
REPO_NAME="writer-app:dev"


DOCKER_IMAGE="$REGISTRY_HOST/$REPO_NAME"
docker build -t $DOCKER_IMAGE $SCRIPT_DIR
docker push $DOCKER_IMAGE