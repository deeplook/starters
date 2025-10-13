# Python ↔ Rust gRPC demo

This repository hosts a minimal gRPC playground showing how a Python component and a Rust component can talk to one another. The same `.proto` contract is shared by both sides. Once things work locally, the services can be moved into Docker containers for a microservice deployment.

## Project layout

```
proto/                 # Shared protobuf definitions
python_service/        # Async Python gRPC server + CLI client
rust_service/          # Rust gRPC server + CLI client (tonic)
```

## Prerequisites

- Python 3.12+
- [`uv`](https://github.com/astral-sh/uv) for dependency and virtualenv management
- Rust toolchain (`rustup`, `cargo`) for the Rust service
- `protoc` compiler is bundled with `grpcio-tools` for Python, so no extra install is necessary

## Bootstrap steps

1. **Install Python deps & generate stubs**
   ```bash
   cd python_service
   uv sync
   uv run ./generate.sh
   ```

2. **Run the Python service**
   ```bash
   cd python_service
   uv run python server.py
   ```

3. **Run the Rust service**
   ```bash
   cd rust_service
   cargo run -- server
   ```

At this point the Python service listens on `0.0.0.0:50051` and the Rust service on `0.0.0.0:50052` (configurable via environment variables).

## Smoke tests

- Call the Rust service from Python:
  ```bash
  cd python_service
  uv run python client.py Alice
  ```
  Expected output (once the Rust server is running):
  ```
  Rust service replied: Hello, Alice! From the Rust service. (source: rust)
  ```

- Call the Python service from Rust:
  ```bash
  cd rust_service
  cargo run -- client Bob
  ```
  Expected output (once the Python server is running):
  ```
  Python service replied: Hello, Bob! From the Python service. (source: python)
  ```

Whenever the Python service processes a request it also calls the Rust service under the hood, so you can see chained responses in the Python logs as well.

## Configuration knobs

| Variable | Default | Used by | Purpose |
|----------|---------|---------|---------|
| `PYTHON_SERVICE_HOST` | `0.0.0.0` | Python server | Bind address |
| `PYTHON_SERVICE_PORT` | `50051` | Python server | Listen port |
| `RUST_SERVICE_ADDR` | `localhost:50052` | Python server/client | Where to reach the Rust service |
| `RUST_SERVICE_HOST` | `0.0.0.0` | Rust server | Bind address |
| `RUST_SERVICE_PORT` | `50052` | Rust server | Listen port |
| `PYTHON_SERVICE_ADDR` | `http://127.0.0.1:50051` | Rust client | Where to reach the Python service |
| `PYTHON_GRPC_ENDPOINT` | `localhost:50051` | Tooling/CLI | Host:port target for Python gRPC calls |
| `RUST_GRPC_ENDPOINT` | `localhost:50052` | Tooling/CLI | Host:port target for Rust gRPC calls |

### Environment files

- `.env` holds local development defaults. Copy `.env.example` to `.env` (and tweak as needed). The Makefile loads it automatically so `make python-server`, `make rust-client`, etc., inherit these values.
- `docker.env` is consumed by `docker compose` to provide container-specific hostnames (e.g. `rust_service:50052`). Copy `docker.env.example` to `docker.env` when running in containers and adjust as needed.

## Docker usage

Two ready-to-build images live alongside the services:

```bash
# Python service
docker build -t python-grpc-service -f python_service/Dockerfile .
docker run --rm -p 50051:50051 python-grpc-service

# Rust service
docker build -t rust-grpc-service -f rust_service/Dockerfile .
docker run --rm -p 50052:50052 rust-grpc-service
```

With server reflection enabled you can explore either service via `grpcurl` without supplying the proto file:

```bash
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext -d '{"name":"Alice"}' localhost:50051 bridge.PythonGreeter/SayHello
grpcurl -plaintext -d '{"name":"Bob"}' localhost:50052 bridge.RustGreeter/SayHello
```

Because the images copy the shared `proto/` directory and regenerate stubs at build time, the services stay in sync automatically. When running side by side, set `PYTHON_SERVICE_ADDR` and `RUST_SERVICE_ADDR` to reference the appropriate container hostnames (e.g. with Docker Compose).

You can also launch both via Docker Compose:

```bash
docker compose up --build  # reads docker.env for container settings
```

The Python container waits for the Rust service to start before it begins accepting requests. Both expose their gRPC ports to the host on `50051` and `50052` respectively, and each container publishes a gRPC health check endpoint so Docker can report readiness (`grpc_health_probe` is baked into the images).

## Makefile shortcuts

Common workflows are wrapped in `make` targets at repo root:

```bash
make python-generate   # uv sync + regenerate Python stubs
make rust-build        # cargo build for the Rust binary
make grpcurl-list-python
make grpcurl-list-rust
make compose-up        # build & run both services with health checks
```

Healthy services respond to the standard probe as well as reflection. For example:

```bash
grpcurl -plaintext localhost:50051 grpc.health.v1.Health/Check -d '{"service":"bridge.PythonGreeter"}'
grpcurl -plaintext localhost:50052 grpc.health.v1.Health/Check -d '{"service":"bridge.RustGreeter"}'
```
