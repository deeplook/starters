#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Tearing down all resources ---"
terraform destroy --auto-approve

echo ""
echo "✅ Teardown complete."
