#!/bin/bash

# Script to build and push a Docker image to AWS ECR

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration (env-aware defaults) ---
AWS_REGION="${AWS_REGION:-eu-central-1}"
PROJECT_NAME="${PROJECT_NAME:-my-web-app}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Construct the repository name
REPOSITORY_NAME="${PROJECT_NAME}-${ENVIRONMENT}"

echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_ROOT=${PROJECT_ROOT}"
if [ ! -f "${PROJECT_ROOT}/Dockerfile" ]; then
  echo "❌ Dockerfile not found at ${PROJECT_ROOT}/Dockerfile"
  ls -la "${PROJECT_ROOT}" || true
  exit 1
fi

# --- AWS Account and ECR login ---
echo "Retrieving AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
if [ $? -ne 0 ] || [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: Failed to retrieve AWS Account ID. Please ensure you are authenticated with AWS CLI."
    exit 1
fi
echo "AWS Account ID: ${AWS_ACCOUNT_ID}"

ECR_REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}"

echo "Authenticating Docker to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
echo "Authentication successful."

# --- Build & Push ---
echo "Building the Docker image from ${PROJECT_ROOT}..."
docker build --platform linux/amd64 -f "${PROJECT_ROOT}/Dockerfile" -t "${REPOSITORY_NAME}:${IMAGE_TAG}" "${PROJECT_ROOT}"
echo "Docker image build successful."

echo "Tagging Docker image for ECR..."
docker tag "${REPOSITORY_NAME}:${IMAGE_TAG}" "${ECR_REPOSITORY_URI}:${IMAGE_TAG}"
echo "Docker image tagged as: ${ECR_REPOSITORY_URI}:${IMAGE_TAG}"

echo "Pushing Docker image to ECR..."
docker push "${ECR_REPOSITORY_URI}:${IMAGE_TAG}"
echo "Docker image pushed successfully."

echo -e "\n\nBuild and push complete."
echo "Repository URI: ${ECR_REPOSITORY_URI}:${IMAGE_TAG}"
