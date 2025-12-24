# Makefile for log-processing project

.PHONY: help install test run loki-dev smoke-test start-grafana stop-grafana clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install       - Install dependencies using uv"
	@echo "  test          - Run tests using pytest"
	@echo "  run           - Run mac_stats and promtail (assumes Loki and Grafana via brew)"
	@echo "  loki-dev      - Run Loki locally with local config"
	@echo "  start-grafana - Start Grafana via Homebrew services"
	@echo "  stop-grafana  - Stop Grafana via Homebrew services"
	@echo "  smoke-test    - Run Loki smoke tests"
	@echo "  clean         - Remove log files and temporary data"

install:
	uv sync

test:
	uv run pytest

run:
	bash ./run_all.sh

loki-dev:
	./scripts/loki_dev.sh

start-grafana:
	brew services start grafana

stop-grafana:
	brew services stop grafana

smoke-test:
	./scripts/loki_smoke.sh

clean:
	rm -f *.log
	rm -f scripts/*.log
	rm -rf .pytest_cache
	rm -rf __pycache__
	# Optional: Clean loki data if you want a fresh start
	# rm -rf .loki-data
