#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hostname or IP>"
    exit 1
fi

HOST=$1

# Check if the container is UP and running
container_status=$(ssh "$USERNAME@$HOST" "docker inspect -f '{{.State.Status}}' $CONTAINER_NAME" 2>/dev/null)

if [ "$container_status" == "running" ]; then
    # If the container is running, SSH into the remote server and execute nodetool status without displaying the "Connection to ... closed" message
    ssh -t "$USERNAME@$HOST" "docker exec -it $CONTAINER_NAME nodetool status"
else
    echo "Error: The Docker container $CONTAINER_NAME is not running on $HOST."
fi
