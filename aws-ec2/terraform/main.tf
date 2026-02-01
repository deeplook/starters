

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "EC2-Starter"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# Dynamic AMI lookup for Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
}

module "security_group" {
  source           = "./modules/security_group"
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "ec2_instance" {
  source            = "./modules/ec2_instance"
  ami_id            = coalesce(var.ami_id, data.aws_ami.amazon_linux_2.id)
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_group.security_group_id
  instance_type     = var.instance_type
  volume_size       = var.ec2_volume_size
}
