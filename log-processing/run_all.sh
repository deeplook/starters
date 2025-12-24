#!/usr/bin/env bash
set -euo pipefail

# Ensures the necessary services are running and starts the mac_stats.py script.
# This script is intended to be run from the project root.
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Function to clean up background processes
cleanup() {
    echo -e "\nShutting down services..."
    kill "${PROMTAIL_PID:-}" >/dev/null 2>&1 || true
    kill "${MAC_STATS_PID:-}" >/dev/null 2>&1 || true
    sleep 1 # Give processes a moment to terminate
    echo "Services stopped."
    echo "To stop Loki, run: brew services stop loki"
    echo "To stop Grafana, run: brew services stop grafana"
}


# Trap SIGINT (Ctrl+C) and call the cleanup function
trap cleanup INT

# --- Service Management ---
# We start Loki and Grafana via Homebrew services.
if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew not found. Please install it to manage Loki/Grafana services." >&2
  exit 1
fi

if ! brew list loki >/dev/null 2>&1; then
  echo "Error: loki is not installed. Install it with: brew install loki" >&2
  exit 1
fi
if ! brew list grafana >/dev/null 2>&1; then
  echo "Error: grafana is not installed. Install it with: brew install grafana" >&2
  exit 1
fi
if ! command -v promtail >/dev/null 2>&1; then
  echo "Error: promtail not found in PATH. Install it (e.g. via Homebrew: brew install promtail)." >&2
  exit 1
fi


# --- Script Execution ---
echo "Starting Loki via Homebrew services..."
if ! brew services list | grep -q "loki.*started"; then
  if ! brew services start loki; then
    echo "Error: Failed to start Loki via brew services." >&2
    echo "If you see 'launchctl bootstrap ... exited with 5', try:" >&2
    echo "  brew services stop loki || true" >&2
    echo "  brew services cleanup" >&2
    echo "  launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/homebrew.mxcl.loki.plist 2>/dev/null || true" >&2
    echo "  rm -f ~/Library/LaunchAgents/homebrew.mxcl.loki.plist" >&2
    echo "  brew services start loki" >&2
    exit 1
  fi
fi
echo "Loki service is running."

echo "Starting Grafana via Homebrew services..."
if ! brew services list | grep -q "grafana.*started"; then
  if ! brew services start grafana; then
    echo "Error: Failed to start Grafana via brew services." >&2
    echo "Try: brew services cleanup && brew services start grafana" >&2
    exit 1
  fi
fi
echo "Grafana service is running."
# Promtail needs to be able to write its positions file. If you previously ran
# this script with sudo, positions.yaml may be owned by root and Promtail will fail.
POSITIONS_FILE="$ROOT_DIR/.promtail-positions.yaml"
if ! touch "$POSITIONS_FILE" >/dev/null 2>&1; then
  echo "Error: Promtail positions file is not writable: $POSITIONS_FILE" >&2
  echo "This is commonly caused by running make/run_all.sh with sudo earlier." >&2
  echo "Fix with:" >&2
  echo "  sudo chown $(whoami):staff \"$POSITIONS_FILE\" && chmod 644 \"$POSITIONS_FILE\"" >&2
  exit 1
fi

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

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi
echo "Loki logs: $BREW_PREFIX/var/log/loki.log"
echo "Grafana logs: $BREW_PREFIX/var/log/grafana/grafana.log"
echo "Promtail logs: $ROOT_DIR/promtail.log"
echo "mac_stats.py logs: $ROOT_DIR/mac_stats.py.log"
echo "Press [CTRL+C] to stop Promtail and mac_stats.py."

# Wait for any of the background jobs to exit
wait
