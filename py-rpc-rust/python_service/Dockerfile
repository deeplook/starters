# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    UV_PROJECT_ENV=.venv

WORKDIR /app

# Install system build tools if future deps need them (grpcio wheels cover most cases)
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.25/grpc_health_probe-linux-amd64 \
    -o /usr/local/bin/grpc_health_probe \
    && chmod +x /usr/local/bin/grpc_health_probe

# Install uv for dependency management inside the image
RUN pip install --no-cache-dir uv

# Copy project files
COPY proto ./proto
COPY python_service ./python_service

WORKDIR /app/python_service

# Ensure scripts are executable
RUN chmod +x generate.sh

# Install dependencies into the managed virtualenv and generate gRPC stubs
RUN uv sync --no-dev \
    && uv run ./generate.sh

EXPOSE 50051

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD grpc_health_probe -addr=localhost:50051 || exit 1

CMD ["uv", "run", "python", "server.py"]
