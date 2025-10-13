# syntax=docker/dockerfile:1
FROM rust:1.77-bullseye AS builder

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

COPY proto ./proto
COPY rust_service/Cargo.toml rust_service/Cargo.toml
COPY rust_service/build.rs rust_service/build.rs
COPY rust_service/src rust_service/src

WORKDIR /app/rust_service

RUN cargo build --release

FROM debian:bullseye-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.25/grpc_health_probe-linux-amd64 \
    -o /usr/local/bin/grpc_health_probe \
    && chmod +x /usr/local/bin/grpc_health_probe

COPY --from=builder /app/target/release/rust_service /usr/local/bin/rust_service

EXPOSE 50052

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD grpc_health_probe -addr=localhost:50052 || exit 1

CMD ["rust_service", "server"]
