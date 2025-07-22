# ------------------------------------------------------------------------------
# GENERAL CONFIGURATION
# ------------------------------------------------------------------------------

variable "project_name" {
  description = "A unique name for the project, used for tagging and naming resources."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'staging', 'prod')."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

# ------------------------------------------------------------------------------
# NETWORKING CONFIGURATION
# ------------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC to deploy into. If not provided, the default VPC will be used."
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# ECS & DOCKER CONFIGURATION
# ------------------------------------------------------------------------------

variable "docker_image_tag" {
  description = "The tag of the Docker image to deploy."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
  default     = 5001
}

variable "container_cpu" {
  description = "The number of CPU units to reserve for the container."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The amount of memory (in MiB) to reserve for the container."
  type        = number
  default     = 512
}

variable "desired_task_count" {
  description = "The desired number of tasks to run for the service."
  type        = number
  default     = 2
}

# ------------------------------------------------------------------------------
# AUTOSCALING CONFIGURATION
# ------------------------------------------------------------------------------

variable "autoscale_min_tasks" {
  description = "The minimum number of tasks for autoscaling."
  type        = number
  default     = 1
}

variable "autoscale_max_tasks" {
  description = "The maximum number of tasks for autoscaling."
  type        = number
  default     = 3
}

variable "autoscale_cpu_target" {
  description = "The target average CPU utilization (in percent) for autoscaling."
  type        = number
  default     = 75
}
