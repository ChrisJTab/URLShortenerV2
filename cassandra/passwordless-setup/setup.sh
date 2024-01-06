#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

REMOTE_USER="$1"

# Local path to .ssh folder
PARENT_DIR_PATH="$(pwd)"
LOCAL_SSH_PATH="$PARENT_DIR_PATH/.ssh"
HOST_FILE="$PARENT_DIR_PATH/hosts"
REMOTE_SSH_PATH="/home/${REMOTE_USER}/.ssh"


if [ ! -f "$HOST_FILE" ]; then
    echo "Error: Host file not found: $HOST_FILE"
    exit 1
fi

# Read IP addresses from the host file
REMOTE_HOSTS=($(cat "$HOST_FILE"))

for REMOTE_HOST in "${REMOTE_HOSTS[@]}"; do
    scp -r "${LOCAL_SSH_PATH}" "${root}@${REMOTE_HOST}:/home/${REMOTE_USER}/"

    # Set correct permissions and ownership on the remote .ssh folder
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "chmod 600 ${REMOTE_SSH_PATH}/* && chown -R ${REMOTE_USER}:${REMOTE_USER} ${REMOTE_SSH_PATH}" > /dev/null 2>&1
done

echo "Setup complete!"
