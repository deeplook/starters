variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., 'dev', 'staging', 'prod')."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to use. If null, the default VPC will be used."
  type        = string
  default     = null
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
}
