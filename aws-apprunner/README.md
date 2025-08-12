# AWS App Runner Deployment

![NodeJS](https://img.shields.io/badge/Node.js-%23339933.svg?style=for-the-badge&logo=node.js&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

This project shows how to build a Node.js app into a Docker image, push it to Amazon ECR, and deploy it on AWS App Runner using Terraform and simple shell scripts. You’ll learn a clean two-module layout (ECR and App Runner), how to parameterize environments, and how to validate the deployment with quick smoke tests or a full end‑to‑end script.

## Prerequisites
- Terraform, AWS CLI, Docker, and Node.js installed
- AWS credentials configured (`aws configure`)

## Configure
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: aws_region, ecr_repository_name, image_tag,
# docker_build_platform, app_service_name, and optionally environment (default: "prod")
```
Note: All `make` commands accept `ENV=<name>` to override the environment (flows into `TF_VAR_environment`). Replace `brew` and `open` commands for macOS used in the scripts with their equivalents for other platforms!

## Quickstart (Create ECR, build, push, deploy)
```bash
make setup         # init Terraform and create ECR
make deploy        # build, push image, and create/update App Runner

# Get and test the service URL
SERVICE_URL=$(make -s url)
curl https://$SERVICE_URL
# Or open in a browser
make open
```
Deploy another environment (suffixes names):
```bash
make deploy ENV=e2e-test
```

## Smoke Testing (scripted)
```bash
make smoke
# or
make smoke ENV=e2e-test
```

## Tearing Down
```bash
make destroy
# or
make destroy ENV=e2e-test
```

## End-to-End Test
```bash
make e2e
```
What it does:
- Creates ECR, builds and pushes the image
- Deploys App Runner and waits for health
- Runs basic checks and tears everything down

## Troubleshooting
- Credentials: verify with `aws sts get-caller-identity`.
- Output missing: ensure `make deploy` completed successfully.
- App Runner warm-up: allow 2–5 minutes after deploy before testing.
- Image arch: set `docker_build_platform` in `terraform.tfvars` (e.g., `linux/amd64`).
- Environment suffix: set `ENV=<name>` for `make` targets or define `environment` in `terraform.tfvars` (default: `prod`).
