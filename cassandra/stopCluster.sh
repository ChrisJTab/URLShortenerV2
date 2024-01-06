#!/bin/bash

USERNAME="student"
CONTAINER_NAME="cassandra-node"


# Get the script's directory
script_dir="$(cd "$(dirname "$0")" && pwd)"

# Project Paths
project_dir="$(cd "$script_dir/../" && pwd)"
cluster_conf_file="$script_dir/cluster.conf"


# Check that the cluster.conf exists
if [ ! -f $cluster_conf_file ]; then
    echo "Please ensure that the file \"$cluster_conf_file\" exist!"
    exit 1
fi

source $cluster_conf_file

if [ "${#HOSTS[@]}" -eq 0 ]; then
    echo "No host IP addresses found in cluster.conf"
    exit 1
fi

# Array to store IP addresses of Cassandra nodes in the cluster
CASSANDRA_NODES=()

# Get the IP address of each node in the cluster that is UN
for HOST in "${HOSTS[@]}"; do
    # Get the IP addresses of all nodes in the Cassandra cluster
    NODE_STATUS=$(ssh -t $USERNAME@$HOST "docker exec -it $CONTAINER_NAME nodetool status" 2>/dev/null | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $2}')

    
    CASSANDRA_NODES+=("$HOST")
    # Add only unique IP addresses to CASSANDRA_NODES
    for IP in $NODE_STATUS; do
        if [[ ! " ${CASSANDRA_NODES[@]} " =~ " $IP " ]]; then
            CASSANDRA_NODES+=("$IP")
        fi
    done
done

# Shutdown each node in the cluster with status UN
for IP in "${CASSANDRA_NODES[@]}"; do
    # Check if the Cassandra Docker container exists on the host
    # if ssh $USERNAME@$IP "docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null" | grep -q -e "running"; then
    if ssh $USERNAME@$IP "docker inspect $CONTAINER_NAME > /dev/null 2>&1"; then
        # Stop and remove the Cassandra Docker container
        echo "Stopping Cassandra node on host: $IP"
        ssh $USERNAME@$IP "docker container stop $CONTAINER_NAME 2>/dev/null; docker container rm $CONTAINER_NAME 2>/dev/null;"
        echo "Cassandra node on $IP stopped and removed."
    else
        echo "No running Cassandra container found on host: $IP"
    fi
    echo ""
done
echo "Cassandra cluster shutdown complete."
