#!/bin/bash

# Get the parent directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Use find to locate all .sh files and apply chmod, excluding the script itself
find "$script_dir" -type f -name "*.sh" ! -samefile "$BASH_SOURCE" -exec chmod +x {} \;
