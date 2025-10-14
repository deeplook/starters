#!/usr/bin/env python3
"""Tiny CLI for testing calls to the Rust gRPC service."""

from __future__ import annotations

import argparse
import asyncio
import os

import grpc

import bridge_pb2
import bridge_pb2_grpc


_DEFAULT_TARGET = os.getenv("RUST_SERVICE_ADDR", "localhost:50052")


async def greet(name: str, target: str) -> None:
    async with grpc.aio.insecure_channel(target) as channel:
        stub = bridge_pb2_grpc.RustGreeterStub(channel)
        response = await stub.SayHello(bridge_pb2.HelloRequest(name=name))
        print(
            f"Rust service replied: {response.message} (source: {response.from_service})"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Call the Rust gRPC service")
    parser.add_argument("name", nargs="?", default="world", help="Name to greet")
    parser.add_argument(
        "--target",
        default=_DEFAULT_TARGET,
        help="Rust service address (default: %(default)s)",
    )
    args = parser.parse_args()

    asyncio.run(greet(args.name, args.target))


if __name__ == "__main__":
    main()
