# Unified developer helpers for the Python ↔ Rust gRPC demo.

ifneq (,$(wildcard .env))
include .env
export
endif

.PHONY: help python-sync python-generate python-server python-client \
	python-clean rust-build rust-server rust-client rust-clean all-clean \
	all-build smoke-test compose-up \
	docker-build-python docker-run-python docker-build-rust docker-run-rust \
	grpcurl-python grpcurl-rust grpcurl-list-python grpcurl-list-rust

PYTHON_SERVICE_HOST ?= 0.0.0.0
PYTHON_SERVICE_PORT ?= 50051
RUST_SERVICE_HOST ?= 0.0.0.0
RUST_SERVICE_PORT ?= 50052
RUST_SERVICE_ADDR ?= localhost:50052
PYTHON_SERVICE_ADDR ?= http://127.0.0.1:50051
PYTHON_GRPC_ENDPOINT ?= localhost:50051
RUST_GRPC_ENDPOINT ?= localhost:50052

PY_CLIENT_NAME ?= world
PY_CLIENT_TARGET ?= $(RUST_SERVICE_ADDR)
RUST_CLIENT_NAME ?= world
RUST_CLIENT_TARGET ?= $(PYTHON_SERVICE_ADDR)

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?#' Makefile | sed 's/:.*?#/ - /'

python-sync:  # Install Python deps with uv inside python_service/
	cd python_service && uv sync

python-generate: python-sync  # Regenerate Python gRPC stubs
	cd python_service && uv run ./generate.sh

python-server: python-generate  # Run the Python gRPC server
	cd python_service && uv run python server.py

python-client: python-generate  # Call the Rust service from Python
	cd python_service && uv run python client.py $(PY_CLIENT_NAME) --target $(PY_CLIENT_TARGET)

python-clean:  # Remove the Python virtualenv and generated stubs
	rm -rf python_service/.venv \
	       python_service/bridge_pb2.py \
	       python_service/bridge_pb2.pyi \
	       python_service/bridge_pb2_grpc.py

rust-build:  # Build the Rust service binary
	cd rust_service && cargo build

rust-server: rust-build  # Run the Rust gRPC server
	cd rust_service && cargo run -- server

rust-client: rust-build  # Call the Python service from Rust
	cd rust_service && PYTHON_SERVICE_ADDR=$(RUST_CLIENT_TARGET) cargo run -- client $(RUST_CLIENT_NAME)

rust-clean:  # Remove the Rust target directory
	rm -rf rust_service/target

all-clean: python-clean rust-clean  # Remove Python virtualenv and Rust artifacts

all-build: python-generate rust-build docker-build-python docker-build-rust  # Build both runtimes and container images

compose-up:  # Build and start both services via Docker Compose
	docker compose up --build

smoke-test:  # Build services, run both locally, execute CLI checks, then stop
	$(MAKE) python-generate >/dev/null
	$(MAKE) rust-build >/dev/null
	@set -e; \
	cleanup_port() { \
	  if command -v lsof >/dev/null 2>&1; then \
	    PIDS=$$(lsof -ti tcp:$$1 2>/dev/null); \
	    if [ -n "$$PIDS" ]; then kill $$PIDS 2>/dev/null || true; sleep 1; fi; \
	  fi; \
	}; \
	cleanup_port $(PYTHON_SERVICE_PORT); \
	cleanup_port $(RUST_SERVICE_PORT); \
	trap 'kill $$(jobs -p) 2>/dev/null || true' EXIT; \
	(cd python_service && uv run python server.py) & \
	sleep 3; \
	(cd rust_service && cargo run -- server) & \
	sleep 3; \
	$(MAKE) python-client >/dev/null; \
	$(MAKE) rust-client >/dev/null

docker-build-python:  # Build the Python service container image
	docker build -t python-grpc-service -f python_service/Dockerfile .

docker-run-python: docker-build-python  # Run the Python service container
	docker run --rm -p $(PYTHON_SERVICE_PORT):$(PYTHON_SERVICE_PORT) python-grpc-service

docker-build-rust:  # Build the Rust service container image
	docker build -t rust-grpc-service -f rust_service/Dockerfile .

docker-run-rust: docker-build-rust  # Run the Rust service container
	docker run --rm -p $(RUST_SERVICE_PORT):$(RUST_SERVICE_PORT) rust-grpc-service

grpcurl-list-python:  # List services exposed by the Python server (reflection)
	grpcurl -plaintext $(PYTHON_GRPC_ENDPOINT) list

grpcurl-list-rust:  # List services exposed by the Rust server (reflection)
	grpcurl -plaintext $(RUST_GRPC_ENDPOINT) list

grpcurl-python:  # Invoke the Python service via grpcurl (reflection-enabled)
	grpcurl -plaintext -d '{"name":"$(PY_CLIENT_NAME)"}' $(PYTHON_GRPC_ENDPOINT) bridge.PythonGreeter/SayHello

grpcurl-rust:  # Invoke the Rust service via grpcurl (reflection-enabled)
	grpcurl -plaintext -d '{"name":"$(RUST_CLIENT_NAME)"}' $(RUST_GRPC_ENDPOINT) bridge.RustGreeter/SayHello
