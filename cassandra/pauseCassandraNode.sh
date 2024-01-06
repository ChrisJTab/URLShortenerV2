#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 IP1 IP2 IP3 ..."
    exit 1
fi

while [ "$#" -gt 0 ]; do
    # Check if the container exists and is running
    if ssh -q -t "$USERNAME@$1" "docker ps -q --filter 'name=$CONTAINER_NAME' 2>/dev/null" > /dev/null 2>&1; then
        # Stop the Cassandra container
        ssh -t "$USERNAME@$1" "docker stop $CONTAINER_NAME" > /dev/null 2>&1
        echo "Cassandra node on $1 stopped."
    else
        echo "Container $CONTAINER_NAME does not exist or is not running on $1."
    fi
    
    shift
done
