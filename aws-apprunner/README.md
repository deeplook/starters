# Terraform AWS App Runner Deployment

This project builds a Docker image for a NodeJS web application, pushes it to AWS ECR and deploys it on AWS App Runner, all managed by Terraform.

## Project Structure

The project is organized into two main Terraform modules:

-   `modules/ecr`: Manages the AWS Elastic Container Registry (ECR) repository.
-   `modules/apprunner`: Manages the AWS App Runner service.

This project uses a single Terraform workspace to manage both the ECR and App Runner resources. The creation of the App Runner service is controlled by a variable, allowing for a two-step deployment process.

-   The `apprunner` module has a dependency on the output of the `ecr` module. Specifically, it reads the `repository_url` from the `ecr` state to configure the App Runner service.

## Configuration

All configuration for this project is managed in a single file.

1.  **Create a configuration file:** Copy the example file to create your own local configuration.
    ```bash
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    ```
    Terraform will automatically load variables from `terraform.tfvars`. This file is ignored by Git, so your local settings will not be checked in.

2.  **Edit `terraform.tfvars`:** Open the `terraform/terraform.tfvars` file and adjust the values to match your requirements (e.g., change the `aws_region`, `app_service_name`, or `docker_build_platform`).

## Getting Started

These instructions will guide you through setting up the infrastructure from scratch.

### Prerequisites

- Terraform CLI installed.
- AWS credentials configured for your environment.
- NPM to build the NodeJS application.
- Docker installed and running.

### 1. Configure Your Deployment

Before you begin, create and review your `terraform.tfvars` file as described in the **Configuration** section above.

### 2. Run the Setup Script

This script will initialize Terraform and create the ECR repository.

```bash
cd terraform
./setup.sh
```

### 3. Build, Push, and Deploy

The `push_image.sh` script performs the following actions:
- Installs NodeJS dependencies.
- Builds the Docker image from the `../NodeApp` directory.
- Pushes the image to your new ECR repository.
- Deploys the App Runner service.

Note: The App Runner service is created only once with the first push. Subsequent pushes to the same image tag will automatically trigger a new deployment.

```bash
./push_image.sh
```

## Smoke Testing

After the `push_image.sh` script has completed, you can perform a smoke test to ensure the service is running.

1.  **Get the Service URL:**

    The App Runner service URL is available as an output of the Terraform configuration. You can retrieve it with the following command:

    ```bash
    terraform output apprunner_service_url
    ```

2.  **Test the Application:**

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

```bash
./teardown.sh
```

## End-to-End Testing

To ensure the entire deployment pipeline is working correctly, an end-to-end test script is provided. This script automates the setup, deployment, verification, and teardown processes.

To run the E2E test, execute the following command from the `terraform` directory:
```bash
./test_e2e.sh
```
The script will:
1.  Create the ECR repository.
2.  Build and push the Docker image.
3.  Deploy the App Runner service.
4.  Poll the service's health check endpoint until it is healthy.
5.  Run a series of smoke tests against the deployed application.
6.  Automatically tear down all created resources.

## Next Steps

This project provides a solid foundation for a containerized application on AWS. Here are some ways you can extend it:

- **Integrate a Database**: Connect your Node.js application to a managed database like Amazon RDS (for relational data) or DynamoDB (for NoSQL). You'll need to update the application code and add the necessary database resources to your Terraform configuration.
- **Add a CI/CD Pipeline**: Automate your deployment process using a CI/CD service like GitHub Actions. Configure a workflow to build and push your Docker image to ECR and run `terraform apply` whenever you push changes to your main branch.
- **Secure Secret Management**: Instead of passing configuration as environment variables, use AWS Secrets Manager to store and retrieve sensitive data like database credentials or API keys.
- **Configure a Custom Domain**: Associate a custom domain with your App Runner service for a professional, production-ready URL.
- **Enable Observability**: Enhance monitoring and debugging by sending custom metrics to CloudWatch, or enable AWS X-Ray for end-to-end tracing of requests through your application.
- **Connect to a VPC**: For applications that need to access resources in a private network, configure a VPC connector for your App Runner service.
