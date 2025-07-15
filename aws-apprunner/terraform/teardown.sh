#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Tearing down App Runner Service ---"
echo "Switching to 'apprunner' workspace..."
terraform workspace select apprunner
echo "Destroying App Runner resources..."
terraform destroy --auto-approve

echo ""
echo "--- Tearing down ECR Repository ---"
echo "Switching to 'ecr' workspace..."
terraform workspace select ecr
echo "Destroying ECR resources..."
terraform destroy --auto-approve

echo ""
echo "--- Cleaning Up Workspaces ---"
echo "Switching to 'default' workspace..."
terraform workspace select default

echo "Deleting 'apprunner' workspace..."
terraform workspace delete apprunner

echo "Deleting 'ecr' workspace..."
terraform workspace delete ecr

echo ""
echo "✅ Teardown complete."
