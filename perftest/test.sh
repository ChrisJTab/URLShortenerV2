#!/bin/bash
URL=$1
NUM_HOSTS=$2
NUM_JOBS=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <URL> <NUM_HOSTS> <NUM_JOBS>"
    exit 1
fi

./writeTest.py $URL $NUM_HOSTS $NUM_JOBS
sleep 5
time parallel --progress --jobs $NUM_HOSTS < write_commands.txt
time parallel --progress --jobs $NUM_HOSTS < read_commands.txt