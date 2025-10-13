#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROTO_DIR="${ROOT_DIR}/proto"
python -m grpc_tools.protoc \
  -I"${PROTO_DIR}" \
  --python_out="${SCRIPT_DIR}" \
  --pyi_out="${SCRIPT_DIR}" \
  --grpc_python_out="${SCRIPT_DIR}" \
  "${PROTO_DIR}/bridge.proto"
