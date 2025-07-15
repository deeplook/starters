# AWS EC2 with Terraform

A minimal example for managing an AWS EC2 instance with Terraform.

## Setup and Usage

This project uses `terraform` to specify and manage the necessary infrastructure.

1.  **Install dependencies:**

```bash
brew install awscli
brew install jq
brew install terraform
```

2.  **Configure the resources:**

Make sure you have `~/.aws/config` and `~/.aws/credentials` in your home directory.

Needs region, aws_access_key_id, and aws_secret_access_key...

```bash
ls -l ~/.aws/config
ls -l ~/.aws/credentials
```

Modify the values in `variables.tf` as needed. An example, more powerful configuration including GPUs would be `instance_type = "g4dn.xlarge"` (needs registration with AWS) and `volume_size = 36`.


3.  **Manage the EC2 instance:**

The terraform manifests are organized in modules as this is critical best practice that improves code reusability, scalability, and maintainability.

### Launch an instance

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### Use the instance

```bash
# Create environment variables file
terraform output -json | jq -r 'to_entries[] | "export \(.key)=\(.value.value)"' > tf_outputs.env

# Open webserver
source tf_outputs.env && open http://$instance_public_ip

# Run command via SSH
source tf_outputs.env && ssh -i $private_key_file ec2-user@$instance_public_ip uname -a
> Linux ip-10-0-1-160.eu-central-1.compute.internal 6.1.140-154.222.amzn2023.x86_64 #1 SMP PREEMPT_DYNAMIC Mon Jun  2 15:11:40 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
```

### Terminate the instance

```bash
terraform destroy

# Manual clean-up local state files
make clean
```
