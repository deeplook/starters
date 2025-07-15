# Terraform AWS App Runner Deployment

This project uses Terraform to deploy a containerized application to AWS App Runner, with the ECR repository managed as a separate component.

## Project Structure

The project is organized into two main Terraform modules:

-   `modules/ecr`: Manages the AWS Elastic Container Registry (ECR) repository.
-   `modules/apprunner`: Manages the AWS App Runner service.

This project uses **Terraform Workspaces** to maintain separate state files for the `ecr` and `apprunner` resources. This allows for independent management of the ECR repository and the App Runner service.

-   The `apprunner` workspace has a dependency on the output of the `ecr` workspace. Specifically, it reads the `repository_url` from the `ecr` state file to configure the App Runner service.

## Configuration

All configuration for this project is managed in a single file.

1.  **Create a configuration file:** Copy the example file to create your own local configuration.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Terraform will automatically load variables from `terraform.tfvars`. This file is ignored by Git, so your local settings will not be checked in.

2.  **Edit `terraform.tfvars`:** Open the `terraform.tfvars` file and adjust the values to match your requirements (e.g., change the `aws_region`, `app_service_name`, or `docker_build_platform`).

## Getting Started

These instructions will guide you through setting up the infrastructure from scratch.

### Prerequisites

-   Terraform CLI installed.
-   AWS credentials configured for your environment.

### 1. Configure Your Deployment

Before you begin, create and review your `terraform.tfvars` file as described in the **Configuration** section above.

### 2. Run the Setup Script

This script will initialize Terraform and create the necessary `ecr` and `apprunner` workspaces for you.

```bash
./setup.sh
```

### 3. Deploy the ECR Repository

Select the `ecr` workspace and deploy the ECR repository.

```bash
terraform workspace select ecr && terraform apply --auto-approve
```

### 4. Build and Push Your Docker Image

The App Runner service needs a Docker image to deploy. The included script will build the image from the `../NodeApp` directory and push it to your new ECR repository.

```bash
./push_image.sh
```

### 5. Deploy the App Runner Service

Now that the image exists in ECR, you can deploy the App Runner service.

```bash
terraform workspace select apprunner && terraform apply --auto-approve
```

## Smoke Testing

After the `apprunner` workspace has been successfully applied, you can perform a smoke test to ensure the service is running.

1.  **Get the Service URL:**

    The App Runner service URL is available as an output of the `apprunner` workspace. You can retrieve it with the following command:

    ```bash
    terraform output apprunner_service_url
    ```

2.  **Test the Endpoint:**

    Use `curl` or your web browser to send a request to the service URL.

    ```bash
    curl https://$(terraform output -raw apprunner_service_url)
    open https://$(terraform output -raw apprunner_service_url)
    ```

    You should receive a response from your application.

## Tearing Down the Infrastructure

To destroy all the resources created by this project, you can run the included teardown script.

This script will:
- Destroy the App Runner service.
- Destroy the ECR repository (including any images).
- Delete the `apprunner` and `ecr` workspaces.

```bash
./teardown.sh
```
