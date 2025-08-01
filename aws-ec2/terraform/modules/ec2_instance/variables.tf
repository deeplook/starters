variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the EC2 instance in."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The type of the EC2 instance."
  type        = string
}

variable "volume_size" {
  description = "The size of the root EBS volume in GB."
  type        = number
}
