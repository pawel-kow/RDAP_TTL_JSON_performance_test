#!/bin/bash

# Check if a data directory path is provided as the first argument
if [ -z "$1" ]; then
    echo "Error: No data directory path provided."
    echo "Usage: $0 /path/to/data [--no-build]"
    echo "   or: $0 path/to/data [--no-build] (relative to current directory)"
    echo "Example: $0 data/all_broken_down_6"
    echo "Example (skip build): $0 data/all_broken_down_6 --no-build"
    exit 1
fi

DATA_PATH_ARG="$1"
SKIP_BUILD_ARG="$2" # Get the second argument
FULL_DATA_PATH=""

# Check if the provided path is absolute or relative
if [[ "$DATA_PATH_ARG" == /* ]]; then
    # Path is absolute
    FULL_DATA_PATH="$DATA_PATH_ARG"
else
    # Path is relative, prepend the current working directory
    FULL_DATA_PATH="$(pwd)/$DATA_PATH_ARG"
fi

# Check if the final directory path actually exists
if [ ! -d "$FULL_DATA_PATH" ]; then
    echo "Error: Directory '$FULL_DATA_PATH' does not exist."
    exit 1
fi

# Check if we should skip the build step
if [ "$SKIP_BUILD_ARG" == "--no-build" ]; then
    echo "Skipping build step as requested."
else
    echo "Building TTL Performance Test Suite..."
    docker build -t ttl-performance-test .

    if [ $? -ne 0 ]; then
        echo "Build failed. Please check the error messages above."
        exit 1
    else
        echo "Build successful!"
    fi
fi

# We only get here if the build was skipped or successful
echo ""
echo "Running tests..."
echo "Mounting data directory: $FULL_DATA_PATH"
echo ""
# Use the resolved FULL_DATA_PATH variable in the volume mount
docker run --rm -v "$FULL_DATA_PATH:/data" ttl-performance-test