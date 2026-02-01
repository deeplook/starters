variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to launch."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the EC2 instance will be launched."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
  type        = string
}

variable "volume_size" {
  description = "The size of the root EBS volume in GB. For development (8-16 GB), staging (16-32 GB), or production (32+ GB). Note that costs increase with size and IOPS. Using gp3 volume type for better price/performance ratio."
  type        = number
}

variable "key_name_prefix" {
  description = "Prefix for the generated SSH key pair name. A random suffix will be added for uniqueness."
  type        = string
  default     = "tf-key"
}
