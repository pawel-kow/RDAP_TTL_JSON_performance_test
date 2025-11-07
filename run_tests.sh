#!/bin/bash

echo "Building TTL Performance Test Suite..."
docker build -t ttl-performance-test .

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful! Running tests..."
    echo ""
    docker run --rm ttl-performance-test
else
    echo "Build failed. Please check the error messages above."
    exit 1
fi
