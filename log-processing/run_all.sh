#!/usr/bin/env bash
set -euo pipefail

# Ensures the necessary services are running and starts the mac_stats.py script.
# This script is intended to be run from the project root.
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Function to clean up background processes
cleanup() {
    echo -e "\nShutting down services..."
    # Use pkill to reliably terminate the processes by name
    pkill -f "promtail-local-config.yaml" || true
    pkill -f "mac_stats.py" || true
    sleep 1 # Give processes a moment to terminate
    echo "Services stopped."
    echo "To stop Loki, run: brew services stop loki"
}


# Trap SIGINT (Ctrl+C) and call the cleanup function
trap cleanup INT

# --- Service Management ---
# Check for Homebrew
if ! command -v brew >/dev/null 2>&1;
then
  echo "Error: Homebrew not found. Please install it to manage the Loki service." >&2
  exit 1
fi

# Check and start Loki service
if ! brew services list | grep -q "loki.*started";
then
    echo "Loki service not running. Starting with Homebrew..."
    brew services start loki
fi
echo "Loki service is running."

# Stop and disable the Promtail service if it's active
if brew services list | grep -q "promtail";
then
    if brew services list | grep -q "promtail.*started";
then
        echo "Stopping conflicting Promtail Homebrew service..."
        brew services stop promtail
    fi
fi


# --- Script Execution ---
# Start Promtail as a background process
echo "Starting Promtail..."
promtail -config.file="$ROOT_DIR/promtail-local-config.yaml" > "$ROOT_DIR/promtail.log" 2>&1 &
PROMTAIL_PID=$!
echo "Promtail started with PID $PROMTAIL_PID"

# Start the mac_stats.py script
echo "Starting mac_stats.py..."
./mac_stats.py > "$ROOT_DIR/mac_stats.py.log" 2>&1 &
MAC_STATS_PID=$!
echo "mac_stats.py started with PID $MAC_STATS_PID"

echo -e "\nAll services are running."
echo "Grafana UI: http://localhost:3000"

# Determine Homebrew prefix for log paths
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

echo "Loki logs: $BREW_PREFIX/var/log/loki.log"
echo "Promtail logs: $ROOT_DIR/promtail.log"
echo "mac_stats.py logs: $ROOT_DIR/mac_stats.py.log"
echo "Press [CTRL+C] to stop Promtail and mac_stats.py."

# Wait for any of the background jobs to exit
wait
