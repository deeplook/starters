#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Build NodeJS application ---
cd ../NodeApp
npm install
cd ../terraform

# --- Configuration ---
# The script assumes your Dockerfile is in a directory named 'app'
# at the same level as your 'terraform' directory.
APP_DIR="../NodeApp"
TF_VARS_FILE="./terraform.tfvars"

if [ ! -f "$TF_VARS_FILE" ]; then
    echo "Error: Configuration file not found!"
    echo "Please create '$TF_VARS_FILE' by copying 'terraform.tfvars.example' and customizing it."
    exit 1
fi

# --- Helper function to parse variables from .tfvars file ---
get_tf_var() {
    local var_name=$1
    local var_value=$(grep -E "^\s*${var_name}\s*=" "$TF_VARS_FILE" | cut -d'=' -f2 | tr -d ' "')
    if [ -z "$var_value" ]; then
        echo "Error: Variable '${var_name}' not found in $TF_VARS_FILE" >&2
        exit 1
    fi
    echo "$var_value"
}

# --- Read variables from terraform.tfvars ---
echo "Reading configuration from $TF_VARS_FILE..."
AWS_REGION=$(get_tf_var "aws_region")
ECR_REPO_NAME=$(get_tf_var "ecr_repository_name")
DOCKER_PLATFORM=$(get_tf_var "docker_build_platform")
IMAGE_TAG=$(get_tf_var "image_tag")

# --- Get AWS Account ID ---
echo "Fetching AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: Failed to get AWS Account ID. Is the AWS CLI configured and authenticated?" >&2
    exit 1
fi

# --- Construct Full ECR Image URI ---
ECR_IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
echo "Constructed ECR Image URI: $ECR_IMAGE_URI"

# --- Build the Docker Image ---
echo "Building Docker image for platform $DOCKER_PLATFORM from $APP_DIR..."
if [ ! -f "$APP_DIR/Dockerfile" ]; then
    echo "Error: Dockerfile not found in $APP_DIR" >&2
    exit 1
fi
docker build --platform "$DOCKER_PLATFORM" -t "$ECR_REPO_NAME:$IMAGE_TAG" "$APP_DIR"

# --- Authenticate Docker to AWS ECR ---
echo "Authenticating Docker to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# --- Tag the Docker Image ---
echo "Tagging image for ECR..."
docker tag "$ECR_REPO_NAME:$IMAGE_TAG" "$ECR_IMAGE_URI"

# --- Push the Docker Image to ECR ---
echo "Pushing image to ECR..."
docker push "$ECR_IMAGE_URI"

echo ""
echo "✅ Successfully pushed image to ECR: $ECR_IMAGE_URI"

# --- Create and deploy App Runner service ---
echo "Creating App Runner service..."
terraform apply --auto-approve -var="create_apprunner_service=true"

echo ""
echo "🚀 Deployment started for App Runner service (this may take a few minutes)."
echo "Service URL: https://$(terraform output -raw app_service_url)"
