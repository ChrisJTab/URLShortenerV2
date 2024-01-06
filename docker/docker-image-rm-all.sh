#!/bin/bash

# Check if there are any Docker images
if [ "$(docker images -q)" ]; then
    # Remove all Docker images forcefully
    docker rmi -f $(docker images -a -q)
fi
