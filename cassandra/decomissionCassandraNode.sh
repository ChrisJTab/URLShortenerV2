#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <Cluster Node IP> IP1 IP2 IP3 ..."
    exit 1
fi


CLUSTER_NODE_IP="$1"

# Check if the node is part of the Cassandra cluster
if ssh -q -t "$USERNAME@$CLUSTER_NODE_IP" "docker exec -it $CONTAINER_NAME nodetool status" | grep -q -e "$CLUSTER_NODE_IP"; then
    echo "Node $CLUSTER_NODE_IP is part of the Cassandra cluster."
else
    echo "Node $CLUSTER_NODE_IP is not part of the Cassandra cluster."
    exit 1
fi

# Decommission the cluster nodes using the for loop
for NODE_IP in "${@:2}"; do
    # Check if the node is part of the Cassandra cluster
    if ssh -q -t "$USERNAME@$NODE_IP" "docker exec -it $CONTAINER_NAME nodetool status" | grep -q -e "$NODE_IP" > /dev/null 2>&1; then
        echo "Decommissioning Cassandra node on host: $NODE_IP"
        ssh -t "$USERNAME@$NODE_IP" "docker exec -it $CONTAINER_NAME nodetool decommission" > /dev/null 2>&1
        echo "Decommission completed for node on host: $NODE_IP"
    else
        echo "Node $NODE_IP is not part of the Cassandra cluster on host: $NODE_IP."
    fi

    # Check if the container exists before attempting to stop and remove it
    if ssh -q -t "$USERNAME@$NODE_IP" "docker ps -q --filter name=$CONTAINER_NAME" | grep -q -e .; then
        # Stop and remove the container
        echo "Started removing container $CONTAINER_NAME on node $NODE_IP..."
        ssh -T "$USERNAME@$NODE_IP" "docker container stop $CONTAINER_NAME && docker container rm $CONTAINER_NAME" > /dev/null 2>&1
        echo "Removed the $CONTAINER_NAME Container on node $NODE_IP!"
    else
        echo "Container $CONTAINER_NAME does not exist on node $NODE_IP. Skipping..."
    fi

    # SSH into the remote host and run nodetool status
    NODE_STATUS=$(ssh "$USERNAME@$CLUSTER_NODE_IP" "docker exec $CONTAINER_NAME nodetool status")

    # Extract Host ID for 10.128.4.37
    HOST_ID=$(echo "$NODE_STATUS" | awk -v ip="${NODE_IP}" '$0 ~ ip {print $(NF-1)}')
    
    # Check if the node is still part of the Cassandra cluster
    if ssh -q -t "$USERNAME@$CLUSTER_NODE_IP" "docker exec -it $CONTAINER_NAME nodetool status" | grep -q -e "$NODE_IP" > /dev/null 2>&1; then
        echo "Forcefully removing Cassandra node from the cluster on host: $CLUSTER_NODE_IP"
        ssh -t "$USERNAME@$CLUSTER_NODE_IP" "docker exec -it $CONTAINER_NAME nodetool removenode -f $HOST_ID" > /dev/null 2>&1
        echo "Node removal completed for host: $NODE_IP"
    else
        echo "Node $NODE_IP is not part of the Cassandra cluster on host: $CLUSTER_NODE_IP."
    fi
    echo ""
done

echo ""
echo "Finished decomission!"
