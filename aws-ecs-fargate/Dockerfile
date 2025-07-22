# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /app

# Install curl and uv
RUN apt-get update && apt-get install -y curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

# Copy project files
COPY pyproject.toml README.md ./
COPY dashboard.py ./

# Build the wheel
RUN uv build --wheel -o /app/dist

# Stage 2: Final image
FROM python:3.12-slim

WORKDIR /app

# Install uv
RUN apt-get update && apt-get install -y curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

# Copy the built wheel from the builder stage
COPY --from=builder /app/dist/*.whl .

# Install the wheel
RUN uv pip install --system *.whl

EXPOSE 5001

# Command to run the application.
CMD ["python", "-m", "dashboard"]