variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "The type of the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
  default     = "ami-0c7076ccf39a16a0c" # Amazon Linux 2 AMI for eu-central-1
}

variable "ec2_volume_size" {
  description = "The size of the root EBS volume in GB for the EC2 instance."
  type        = number
  default     = 30
}
