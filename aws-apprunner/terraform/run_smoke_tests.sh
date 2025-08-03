#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Application Smoke Tests ---

if [ -z "$1" ]; then
    echo "❌ ERROR: Service URL not provided."
    echo "Usage: $0 <service_url>"
    exit 1
fi

SERVICE_URL=$1
HEALTH_ENDPOINT="https://${SERVICE_URL}/health"

echo "--- 🔬 Running E2E Verification on $SERVICE_URL ---"

# Poll the health check endpoint until the service is ready
MAX_RETRIES=30
RETRY_INTERVAL=10
echo "Waiting for service to become healthy..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_ENDPOINT")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Service is healthy!"
        break
    fi
    echo "Attempt $i/$MAX_RETRIES: Service not ready (HTTP $HTTP_STATUS). Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
done

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "❌ ERROR: Service did not become healthy in time."
    exit 1
fi

# Run application tests
echo "--- Running Application Smoke Tests ---"

# Test 1: Health check endpoint
echo "Testing GET /health..."
HEALTH_RESPONSE=$(curl -s "$HEALTH_ENDPOINT")
if ! echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
    echo "❌ FAILED: Health check did not return a healthy status."
    exit 1
fi
echo "✅ PASSED: GET /health"

# Test 2: Root endpoint
echo "Testing GET /..."
ROOT_RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${SERVICE_URL}/")
if [ "$ROOT_RESPONSE_CODE" -ne 200 ]; then
    echo "❌ FAILED: Root endpoint returned status $ROOT_RESPONSE_CODE."
    exit 1
fi
echo "✅ PASSED: GET /"

# Test 3: Users endpoint
echo "Testing GET /users..."
USERS_RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${SERVICE_URL}/users")
if [ "$USERS_RESPONSE_CODE" -ne 200 ]; then
    echo "❌ FAILED: Users endpoint returned status $USERS_RESPONSE_CODE."
    exit 1
fi
echo "✅ PASSED: GET /users"

# Test 4: Not Found endpoint
echo "Testing GET /nonexistent-page..."
NOT_FOUND_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${SERVICE_URL}/nonexistent-page")
if [ "$NOT_FOUND_CODE" -ne 404 ]; then
    echo "❌ FAILED: Non-existent page returned status $NOT_FOUND_CODE, expected 404."
    exit 1
fi
echo "✅ PASSED: GET /nonexistent-page"


echo ""
echo "--- 🎉 All smoke tests passed successfully! ---"
