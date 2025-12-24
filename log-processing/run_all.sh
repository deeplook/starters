#!/usr/bin/env bash
set -euo pipefail

# Ensures the necessary services are running and starts the mac_stats.py script.
# This script is intended to be run from the project root.
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Determine Homebrew prefix for paths (macOS Intel vs Apple Silicon)
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

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

ensure_grafana_provisioning() {
  # Install provisioning files into Homebrew Grafana so first-run has:
  # - Loki datasource named "Loki" (http://localhost:3100)
  # - Mac stats dashboard from mac_stats_dashboard.json
  local grafana_provisioning_dir="$BREW_PREFIX/etc/grafana/provisioning"
  local ds_dir="$grafana_provisioning_dir/datasources"
  local dashboards_dir="$grafana_provisioning_dir/dashboards"

  local repo_ds="$ROOT_DIR/grafana/provisioning/datasources/loki.yaml"
  local repo_provider_tpl="$ROOT_DIR/grafana/provisioning/dashboards/provider.yaml"
  local repo_dashboard="$ROOT_DIR/mac_stats_dashboard.json"

  if [ ! -f "$repo_ds" ] || [ ! -f "$repo_provider_tpl" ] || [ ! -f "$repo_dashboard" ]; then
    echo "Error: Grafana provisioning files missing in repo." >&2
    echo "Expected:" >&2
    echo "  $repo_ds" >&2
    echo "  $repo_provider_tpl" >&2
    echo "  $repo_dashboard" >&2
    exit 1
  fi

  if ! mkdir -p "$ds_dir" "$dashboards_dir" >/dev/null 2>&1; then
    echo "Error: Cannot create Grafana provisioning dirs under $BREW_PREFIX/etc/grafana." >&2
    echo "Fix with:" >&2
    echo "  sudo mkdir -p \"$ds_dir\" \"$dashboards_dir\"" >&2
    echo "  sudo chown -R $(whoami):admin \"$BREW_PREFIX/etc/grafana\"" >&2
    exit 1
  fi

  # Datasource
  if ! cp "$repo_ds" "$ds_dir/loki.yaml" >/dev/null 2>&1; then
    echo "Error: Cannot write Grafana datasource provisioning file: $ds_dir/loki.yaml" >&2
    echo "Fix with:" >&2
    echo "  sudo cp \"$repo_ds\" \"$ds_dir/loki.yaml\"" >&2
    exit 1
  fi

  # Dashboard JSON
  if ! cp "$repo_dashboard" "$dashboards_dir/mac_stats_dashboard.json" >/dev/null 2>&1; then
    echo "Error: Cannot write Grafana dashboard file: $dashboards_dir/mac_stats_dashboard.json" >&2
    echo "Fix with:" >&2
    echo "  sudo cp \"$repo_dashboard\" \"$dashboards_dir/mac_stats_dashboard.json\"" >&2
    exit 1
  fi

  # Dashboard provider (render absolute path)
  if ! sed "s|__DASHBOARDS_PATH__|$dashboards_dir|g" "$repo_provider_tpl" > "$dashboards_dir/provider.yaml" 2>/dev/null; then
    echo "Error: Cannot render Grafana dashboard provider config." >&2
    echo "Fix with:" >&2
    echo "  sudo sh -c 'sed \"s|__DASHBOARDS_PATH__|$dashboards_dir|g\" \"$repo_provider_tpl\" > \"$dashboards_dir/provider.yaml\"'" >&2
    exit 1
  fi
}


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

echo "Installing Grafana provisioning (Loki datasource + Mac Stats dashboard)..."
ensure_grafana_provisioning

echo "Starting Grafana via Homebrew services..."
if ! brew services list | grep -q "grafana.*started"; then
  if ! brew services start grafana; then
    echo "Error: Failed to start Grafana via brew services." >&2
    echo "Try: brew services cleanup && brew services start grafana" >&2
    exit 1
  fi
else
  # Ensure new/updated provisioning files are picked up.
  brew services restart grafana >/dev/null 2>&1 || true
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
echo "Loki logs: $BREW_PREFIX/var/log/loki.log"
echo "Grafana logs: $BREW_PREFIX/var/log/grafana/grafana.log"
echo "Promtail logs: $ROOT_DIR/promtail.log"
echo "mac_stats.py logs: $ROOT_DIR/mac_stats.py.log"
echo "Press [CTRL+C] to stop Promtail and mac_stats.py."

# Wait for any of the background jobs to exit
wait
