variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type to use. Choose based on your needs: t2/t3.micro for testing, t2/t3.small for development, t2/t3.medium or larger for production. Note that not all instance types are available in all regions."
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}

variable "ec2_volume_size" {
  description = "The size of the root EBS volume in GB for the EC2 instance."
  type        = number
}

variable "environment" {
  description = "Environment name to suffix resource identifiers and tags (e.g., prod, staging, e2e-test)."
  type        = string
  default     = "prod"
}
