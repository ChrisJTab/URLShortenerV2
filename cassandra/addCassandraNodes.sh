#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"

# Get the script's directory
script_dir="$(cd "$(dirname "$0")" && pwd)"

# Project Paths
project_dir="$(cd "$script_dir/../" && pwd)"
cassandra_data_dir="$project_dir/data/cassandra"

# Function to check if a Cassandra node is already part of the cluster
is_node_in_cluster() {
    local node=$1
    ssh -q -t "$USERNAME@$node" "docker exec -it $CONTAINER_NAME nodetool status" | grep -q -e "$node"
}

# Function to stop and remove a Cassandra container
stop_and_remove_container() {
    local node=$1
    ssh -T "$USERNAME@$node" "docker container stop $CONTAINER_NAME && docker container rm $CONTAINER_NAME" > /dev/null 2>&1
}

# Function to wait for a Cassandra node to be online
wait_for_node_online() {
    local node=$1
    echo "Waiting for Cassandra node on $node to be online..."
    while true; do
        STATUS=$(ssh -t "$USERNAME@$node" "docker exec -it $CONTAINER_NAME nodetool status" 2>/dev/null | grep -e "$node")
        STATUSUN=$(echo "$STATUS" | grep -e "UN")
        [[ ! -z "$STATUSUN" ]] && break
        sleep 5
    done
    echo "Cassandra node $node is up!"
    echo ""
}

# Check if the required argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <SEED_NODE> IP1 IP2 IP3"
    exit 1
fi
SEED_NODE="$1"
shift  # Shift to the remaining IPs

new_nodes=("$@")
for NODE in "${new_nodes[@]}"; do
    if is_node_in_cluster "$NODE"; then
        echo "Cassandra node $NODE is already up on this node. Skipping creation..."
        echo ""
        continue
    fi

    echo "Cassandra node $NODE is down. Started creating it ..."

    # Determine if the current node is the seed node
    if [ "$NODE" == "$SEED_NODE" ]; then
        # For the seed node, disable caching
        COMMAND="docker run --name $CONTAINER_NAME -d --restart always \
            -e CASSANDRA_BROADCAST_ADDRESS=$NODE \
            -p 7000:7000 -p 9042:9042 \
            cassandra:latest"
    else
        # For non-seed nodes, include the CASSANDRA_SEEDS parameter
        COMMAND="docker run --name $CONTAINER_NAME -d --restart always \
            -e CASSANDRA_BROADCAST_ADDRESS=$NODE \
            -e CASSANDRA_SEEDS=$SEED_NODE \
            -p 7000:7000 -p 9042:9042 \
            cassandra:latest"
    fi

    stop_and_remove_container "$NODE"
    ssh -t "$USERNAME@$NODE" "$COMMAND" > /dev/null 2>&1

    wait_for_node_online "$NODE"
done

echo ""
echo "Finished setting up the cluster!"
