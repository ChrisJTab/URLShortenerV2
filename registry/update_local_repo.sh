#!/bin/bash

# Target registry host
local_registry="registry-server.taild476f.ts.net"

# Specify the file containing the list of repositories
repo_file="repos.txt"


# Push to local host command
push_image() {
    local image_name="$1"

    # Pull the image from Docker Hub
    docker pull ${image_name}

    # Tag and push the image to the local registry
    docker tag ${image_name} ${local_registry}/${image_name} > /dev/null 2>&1
    docker push ${local_registry}/${image_name}

    # Remove the temporarily pulled image
    docker image rm ${local_registry}/${image_name} > /dev/null 2>&1
}


# Check if the file exists
if [ -f "$repo_file" ]; then
    # Read each line from the file and call push_image function
    while IFS= read -r repo || [[ -n "$repo" ]]; do
        echo "Processing repository: $repo"
        push_image "$repo"
        echo "------------------------"
        echo ""
        echo ""
    done < "$repo_file"
else
    echo "Error: File $repo_file not found."
fi