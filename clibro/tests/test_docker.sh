#!/bin/bash

set -e

# Get the project version from pyproject.toml
VERSION=$(grep "^version" pyproject.toml | awk -F' = ' '{print $2}' | tr -d '"')
IMAGE_NAME="clibro-test"

echo "Building Docker image with tag: $IMAGE_NAME"
docker build -t $IMAGE_NAME .

echo "Running container and checking version..."
OUTPUT=$(docker run --rm $IMAGE_NAME --version)

# The output is expected to be "clibro version: 0.1.0"
EXPECTED_OUTPUT="clibro version: $VERSION"

if [ "$OUTPUT" == "$EXPECTED_OUTPUT" ]; then
    echo "Success: Output matches expected version."
    exit 0
else
    echo "Error: Output does not match expected version."
    echo "Expected: $EXPECTED_OUTPUT"
    echo "Got: $OUTPUT"
    exit 1
fi
