#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Initializing Terraform..."
terraform init

echo "Setting up workspaces..."
# Switch to default to ensure we can create the new workspaces
terraform workspace select default > /dev/null

# Check if workspace exists before creating.
if ! terraform workspace list | grep -q 'ecr'; then
  echo "Creating 'ecr' workspace..."
  terraform workspace new ecr
else
  echo "Workspace 'ecr' already exists."
fi

if ! terraform workspace list | grep -q 'apprunner'; then
  echo "Creating 'apprunner' workspace..."
  terraform workspace new apprunner
else
  echo "Workspace 'apprunner' already exists."
fi

terraform workspace select default > /dev/null

echo ""
echo "Setup complete. You can now select a workspace to begin:"
echo "  terraform workspace select ecr"
echo "  terraform workspace select apprunner"
