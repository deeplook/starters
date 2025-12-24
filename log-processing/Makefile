# Makefile for log-processing project

.PHONY: help install test run run-all loki-dev smoke-test clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install dependencies using uv"
	@echo "  test         - Run tests using pytest"
	@echo "  run          - Run mac_stats and promtail (assumes Loki via brew)"
	@echo "  run-all      - Run Loki, Promtail, and mac_stats locally"
	@echo "  loki-dev     - Run Loki locally with local config"
	@echo "  smoke-test   - Run Loki smoke tests"
	@echo "  clean        - Remove log files and temporary data"

install:
	uv sync

test:
	uv run pytest

run:
	./run_all.sh

run-all:
	./scripts/run_all_processes.sh

loki-dev:
	./scripts/loki_dev.sh

smoke-test:
	./scripts/loki_smoke.sh

clean:
	rm -f *.log
	rm -f scripts/*.log
	rm -rf .pytest_cache
	rm -rf __pycache__
	# Optional: Clean loki data if you want a fresh start
	# rm -rf .loki-data
