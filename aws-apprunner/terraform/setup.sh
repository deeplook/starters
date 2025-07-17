#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Initializing Terraform..."
terraform init

echo "Creating ECR repository..."
terraform apply --auto-approve -var="create_apprunner_service=false"

echo ""
echo "Setup complete."
echo "You can now push your image to ECR and deploy to App Runner by running:"
echo "  ./push_image.sh"
