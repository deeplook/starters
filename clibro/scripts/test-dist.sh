#!/bin/bash
set -e

echo "--- Building and testing distribution wheel ---"
# Ensure we are in the project root
cd "$(dirname "$0")/.."

rm -rf dist/
uv build --wheel

WHEEL_FILE=$(find dist -name "*.whl" | head -n 1)

if [ -z "$WHEEL_FILE" ]; then
    echo "Error: No wheel file found."
    exit 1
fi

echo "Found wheel: $WHEEL_FILE"

TEST_DIR=$(mktemp -d)
trap 'echo "--- Cleaning up ---"; rm -rf "$TEST_DIR"' EXIT

echo "Creating temporary venv in $TEST_DIR"
uv venv "$TEST_DIR" > /dev/null

echo "Installing $WHEEL_FILE into temporary venv"
uv pip install --python "$TEST_DIR/bin/python" "$WHEEL_FILE" > /dev/null

echo "Verifying installation by running the CLI"
"$TEST_DIR/bin/clibro" --version

echo "--- Distribution test successful! ---"

echo "--- Removing temporary venv ---"
rm -rf "$TEST_DIR"
