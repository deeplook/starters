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
  description = "The type of the EC2 instance."
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
