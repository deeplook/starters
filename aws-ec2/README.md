# AWS EC2 with Terraform

A minimal example for managing an AWS EC2 instance with Terraform. This project demonstrates infrastructure-as-code best practices by organizing resources into reusable modules.

## Project Structure

The Terraform configuration is located in the `terraform` directory and is structured into several modules to promote reusability and maintainability:

-   `modules/vpc`: Manages the Virtual Private Cloud (VPC), subnets, and routing.
-   `modules/security_group`: Manages the security groups to control inbound and outbound traffic.
-   `modules/ec2_instance`: Manages the EC2 instance itself, including its configuration, key pair, and storage.

## Configuration

All configuration for this project is managed through Terraform variables.

1.  **Prerequisites:** Ensure you have the following tools installed.
    ```bash
    brew install awscli jq terraform
    ```

2.  **AWS Credentials:** Make sure your AWS credentials are configured in `~/.aws/config` and `~/.aws/credentials`.

3.  **Review Variables:** Key variables are defined in `terraform/variables.tf`. You can override the defaults by creating a `terraform.tfvars` file or by passing them on the command line. Common variables to customize include:
    - `region`: The AWS region for deployment.
    - `instance_type`: The EC2 instance type (e.g., `t2.micro`).
    - `ami_id`: The Amazon Machine Image to use.
    - `ec2_volume_size`: The size of the root EBS volume.

## Getting Started

These instructions will guide you through deploying the EC2 instance.

### 1. Initialize Terraform

Navigate to the `terraform` directory and initialize the project. This will download the necessary providers.
```bash
cd terraform
terraform init
```

### 2. Deploy the Infrastructure

Apply the Terraform configuration to create the AWS resources. You will be prompted to confirm the changes before they are applied.
```bash
terraform validate
terraform plan
terraform apply
```

## Smoke Testing

After the `terraform apply` has completed, you can perform a smoke test to ensure the instance is running and accessible.

1.  **Get Instance Details:**

    The instance's public IP and the path to the SSH private key are available as Terraform outputs.

    ```bash
    # Get the public IP
    terraform output -raw instance_public_ip

    # Get the path to the private key
    terraform output -raw private_key_file
    ```

2.  **Test the Application:**

    The EC2 instance is configured to run an Nginx web server. Use `curl` or your web browser to send a request to the instance's IP address.

    ```bash
    # Test with curl
    curl http://$(terraform output -raw instance_public_ip)

    # Or open in a browser
    open http://$(terraform output -raw instance_public_ip)
    ```
    You can also connect to the instance via SSH:
    ```bash
    ssh -i $(terraform output -raw private_key_file) ec2-user@$(terraform output -raw instance_public_ip) "uname -a"
    ```

## Tearing Down the Infrastructure

To destroy all the resources created by this project, run the following command from the `terraform` directory:

```bash
terraform destroy
```

## End-to-End Testing

To ensure the entire deployment pipeline is working correctly, an end-to-end test script is provided. This script automates the setup, deployment, verification, and teardown processes.

To run the E2E test, execute the following command from the `terraform` directory:
```bash
./test_e2e.sh
```
The script will:
1.  Initialize and apply the Terraform configuration to create the EC2 instance.
2.  Poll the instance's web server until it is healthy.
3.  Perform an SSH command to verify remote access.
4.  Automatically tear down all created resources upon completion.

## Next Steps

This project provides a solid foundation for managing EC2 instances with Terraform. Here are some ways you could extend it:

- **Advanced User Data:** Customize the `user_data` script in `modules/ec2_instance/main.tf` to install and configure your own applications.
- **Integrate a Database**: Provision a managed database like Amazon RDS and configure the EC2 instance to connect to it.
- **Add a CI/CD Pipeline**: Automate your deployment process using a CI/CD service like GitHub Actions to run `terraform apply` on changes to your main branch.
- **Secure Secret Management**: Use AWS Secrets Manager to handle sensitive data instead of storing it in configuration files.
- **Configure a Custom Domain**: Use Amazon Route 53 to associate a custom domain with your EC2 instance.
