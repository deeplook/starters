#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- E2E Test for AWS EC2 Deployment ---

# Ensure we are in the terraform directory
cd "$(dirname "$0")"

# Function to ensure teardown is always called
cleanup() {
    echo ""
    echo "--- 🧹 Running cleanup ---"
    terraform destroy -auto-approve
}

# Trap EXIT signal to run cleanup function
trap cleanup EXIT

# --- 1. Setup and Deployment Phase ---
echo "--- 🚀 Starting E2E Test: Setup and Deploy ---"
if [ ! -f "./terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
fi
terraform init
terraform validate
terraform apply -auto-approve

# --- 2. Verification Phase ---
echo "--- 🔬 Starting E2E Test: Verification ---"
INSTANCE_IP=$(terraform output -raw instance_public_ip)
PRIVATE_KEY_FILE=$(terraform output -raw private_key_file)

if [ -z "$INSTANCE_IP" ]; then
    echo "❌ ERROR: Failed to get EC2 instance public IP."
    exit 1
fi

if [ -z "$PRIVATE_KEY_FILE" ]; then
    echo "❌ ERROR: Failed to get private key file path."
    exit 1
fi

echo "Instance IP: ${INSTANCE_IP}"
echo "Private key file: ${PRIVATE_KEY_FILE}"

# Poll the web server until it is ready
MAX_RETRIES=30
RETRY_INTERVAL=10
echo "Waiting for web server to become ready..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    HTTP_STATUS=$(curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}" "http://${INSTANCE_IP}" || true)
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ Web server is healthy!"
        sleep 5
        break
    fi
    echo "Attempt $i/$MAX_RETRIES: Web server not ready (HTTP $HTTP_STATUS). Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
done

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "❌ ERROR: Web server did not become ready in time."
    exit 1
fi

# Test SSH connection
echo "--- Testing SSH connection ---"
SSH_COMMAND="ssh -i ${PRIVATE_KEY_FILE} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${INSTANCE_IP} uname -a"
echo "Running: ${SSH_COMMAND}"
SSH_OUTPUT=$($SSH_COMMAND)

if [[ "$SSH_OUTPUT" == *"Linux"* ]]; then
    echo "✅ SSH connection successful."
    echo "Kernel info: $SSH_OUTPUT"
else
    echo "❌ FAILED: SSH connection test failed."
    exit 1
fi

echo ""
echo "--- 🎉 All E2E tests passed successfully! ---"

# The 'trap' will handle the cleanup automatically upon exit
