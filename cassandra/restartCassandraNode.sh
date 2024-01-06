#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"

if [ "$#" == "0" ]; then
    echo "Usage: $0 IP1 IP2 IP3 ..."
    exit 1
fi

while (( "$#" )); do
    # Check if the container is stopped
    if ssh -q -t $USERNAME@$1 "docker ps -q --filter 'name=$CONTAINER_NAME' --filter 'status=exited' | grep -q -e ." > /dev/null 2>&1; then
        # Restart the Cassandra container
        ssh -t $USERNAME@$1 "docker start $CONTAINER_NAME" > /dev/null 2>&1
        echo "Cassandra node on $1 restarted."
    else
        echo "Container $CONTAINER_NAME is not stopped on $1."
    fi
    
    shift
done