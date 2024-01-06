#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo $SCRIPT_DIR

FLASK_APP_BUILDER="$SCRIPT_DIR/flask-app/docker-build-push.sh"
if [ -f "$FLASK_APP_BUILDER" ]; then
    ${FLASK_APP_BUILDER}
else
    echo "Error: docker-build-push.sh not found in $FLASK_APP_BUILDER"
fi


WRITER_APP_BUILDER="$SCRIPT_DIR/writer-app/docker-build-push.sh"
if [ -f "$WRITER_APP_BUILDER" ]; then
	${WRITER_APP_BUILDER}
else
    echo "Error: docker-build-push.sh not found in $WRITER_APP_BUILDER"
fi
