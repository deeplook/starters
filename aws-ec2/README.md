# AWS EC2 Deployment

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

This project is a minimal, practical guide to provisioning a secure EC2 instance with Terraform. It shows how to structure Terraform manifests into reusable modules (VPC, security group, EC2), set sane defaults, expose useful outputs, and validate a deployment with quick smoke tests and an end‑to‑end test script.

## Prerequisites
- Terraform and AWS CLI installed
- Docker installed and running (for local tooling)
- AWS credentials configured (`aws configure`)

## Configure
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: region, ami_id, instance_type,
# vpc_cidr, subnet_cidr, ec2_volume_size
```
Note: Replace macOS-specific commands (e.g., `open`) with platform equivalents as needed.

## Quickstart (Provision VPC + EC2)
```bash
make setup     # initialize Terraform and bootstrap tfvars if missing
make deploy    # create/update VPC, security group, and EC2 instance

# Get and test the instance URL
make url       # prints http://<public-ip>
make open      # opens browser on macOS
```
Deploy another environment (suffixes tags via TF_VAR_environment):
```bash
make deploy ENV=e2e-test
```

## Smoke Testing (scripted)
```bash
make smoke
# or run individually
make smoke-http   # HTTP-only check
make smoke-ssh    # SSH-only check
```

## SSH (optional)
Prefer `make smoke-ssh` for a quick check. To open an SSH session manually:
```bash
IP=$(make -s ip)
KEY=$(cd terraform && echo "$(pwd)/$(terraform output -raw private_key_file)")
ssh -i "$KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  ec2-user@"$IP" "uname -a"
```

## Tearing Down
```bash
make destroy
```

## End-to-End Test
```bash
make e2e
```
What it does:
- Initializes and applies the stack
- Waits for health and runs basic checks (HTTP + SSH)
- Cleans up all resources

## Troubleshooting
- Credentials: verify with `aws sts get-caller-identity`.
- AMI and region: ensure `ami_id` exists in your chosen `region`.
- Connectivity: allow inbound HTTP/80 from your IP; wait 1–2 minutes for instance boot.
- Non-macOS: replace `open` with your platform’s equivalent to open a URL.
