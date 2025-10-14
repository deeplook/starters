#!/usr/bin/env python3
"""Async gRPC server exposing the PythonGreeter service."""

from __future__ import annotations

import asyncio
import logging
import os

import grpc
from grpc_health.v1 import health, health_pb2, health_pb2_grpc
from grpc_reflection.v1alpha import reflection

import bridge_pb2
import bridge_pb2_grpc


_LOGGER = logging.getLogger("python_service.server")

_HOST = os.getenv("PYTHON_SERVICE_HOST", "0.0.0.0")
_PORT = int(os.getenv("PYTHON_SERVICE_PORT", "50051"))
_LISTEN_ADDR = f"{_HOST}:{_PORT}"

_RUST_SERVICE_ADDR = os.getenv("RUST_SERVICE_ADDR", "localhost:50052")

# Register both services so grpcurl/other tooling can discover the API via reflection.
_PYTHON_SERVICE_NAME = bridge_pb2.DESCRIPTOR.services_by_name["PythonGreeter"].full_name
_REFLECTION_SERVICE_NAMES = (
    _PYTHON_SERVICE_NAME,
    reflection.SERVICE_NAME,
)


class PythonGreeter(bridge_pb2_grpc.PythonGreeterServicer):
    """Implement the PythonGreeter service."""

    async def SayHello(
        self, request: bridge_pb2.HelloRequest, context: grpc.aio.ServicerContext
    ) -> bridge_pb2.HelloReply:
        """Return a greeting and optionally show connectivity to the Rust service."""
        _LOGGER.info("Received greeting request for name=%s", request.name)

        rust_message: str | None = None
        try:
            async with grpc.aio.insecure_channel(_RUST_SERVICE_ADDR) as channel:
                stub = bridge_pb2_grpc.RustGreeterStub(channel)
                rust_response = await stub.SayHello(
                    bridge_pb2.HelloRequest(name=request.name)
                )
                rust_message = rust_response.message
        except grpc.aio.AioRpcError as err:
            # It's acceptable during local dev if the Rust side is not yet running.
            _LOGGER.warning(
                "Rust service unavailable at %s (%s)", _RUST_SERVICE_ADDR, err.details()
            )

        message = f"Hello, {request.name}! From the Python service."
        if rust_message:
            message += f" Also heard from Rust: '{rust_message}'."

        return bridge_pb2.HelloReply(message=message, from_service="python")


async def serve() -> None:
    """Start the Python gRPC server."""
    server = grpc.aio.server()
    bridge_pb2_grpc.add_PythonGreeterServicer_to_server(PythonGreeter(), server)

    # Expose gRPC server reflection so tooling (e.g. grpcurl) can discover methods.
    reflection.enable_server_reflection(_REFLECTION_SERVICE_NAMES, server)

    # Register the health check service and mark this server as SERVING.
    health_servicer = health.HealthServicer()
    health_pb2_grpc.add_HealthServicer_to_server(health_servicer, server)
    health_servicer.set("", health_pb2.HealthCheckResponse.SERVING)
    health_servicer.set(_PYTHON_SERVICE_NAME, health_pb2.HealthCheckResponse.SERVING)
    server.add_insecure_port(_LISTEN_ADDR)

    _LOGGER.info("Starting Python gRPC server on %s", _LISTEN_ADDR)
    await server.start()
    await server.wait_for_termination()


def main() -> None:
    """Main entry point."""
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(message)s")
    asyncio.run(serve())


if __name__ == "__main__":
    main()
