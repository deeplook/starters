#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- E2E Test for AWS ECS Fargate Deployment ---

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

# --- 1. Setup Phase ---
echo "--- 🚀 Starting E2E Test: Setup ---"
if [ ! -f "./terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
fi
terraform init
terraform apply -auto-approve

# --- 2. Deployment Phase ---
echo "--- 📦 Starting E2E Test: Build and Push Docker Image ---"
# The build script is in the terraform directory
./build-and-push.sh

# --- 3. Verification Phase ---
echo "--- 🔬 Starting E2E Test: Verification ---"
SERVICE_URL=$(terraform output -raw load_balancer_dns_name)

if [ -z "$SERVICE_URL" ]; then
    echo "❌ ERROR: Failed to get Load Balancer DNS name."
    exit 1
fi

echo "Service URL: http://${SERVICE_URL}"
HEALTH_ENDPOINT="http://${SERVICE_URL}/"

# Poll the health check endpoint until the service is ready
# ECS can take a few minutes to provision and start the tasks.
MAX_RETRIES=60
RETRY_INTERVAL=15
echo "Waiting for service to become healthy..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    # Use -f to fail silently on server errors, which is expected while the service is starting up.
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -f "$HEALTH_ENDPOINT" || true)
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Service is healthy!"
        break
    fi
    echo "Attempt $i/$MAX_RETRIES: Service not ready (HTTP $HTTP_STATUS). Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
done

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "❌ ERROR: Service did not become healthy in time."
    # Provide debugging information
    echo "--- ECS Service Status ---"
    PROJECT_NAME=$(grep 'project_name' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    ENVIRONMENT=$(grep 'environment' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    CLUSTER_NAME="${PROJECT_NAME}-${ENVIRONMENT}-cluster"
    SERVICE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-service"
    aws ecs describe-services --cluster "$CLUSTER_NAME" --services "$SERVICE_NAME" | jq '.services[0] | {runningCount, desiredCount, pendingCount, events: .events[:5]}'
    exit 1
fi

# Run application smoke test
echo "--- Running Application Smoke Test ---"

# Test 1: Root endpoint
echo "Testing GET /..."
ROOT_RESPONSE=$(curl -s "$HEALTH_ENDPOINT")
if ! echo "$ROOT_RESPONSE" | grep -q 'Dashboard'; then
    echo "❌ FAILED: Root endpoint did not contain expected content 'Dashboard'."
    echo "Response: $ROOT_RESPONSE"
    exit 1
fi
echo "✅ PASSED: GET /"

echo ""
echo "--- 🎉 All E2E tests passed successfully! ---"

# The 'trap' will handle the cleanup automatically upon exit
