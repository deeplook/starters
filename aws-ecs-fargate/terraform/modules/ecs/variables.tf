variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., 'dev', 'staging', 'prod')."
  type        = string
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
}

variable "container_cpu" {
  description = "The CPU units to allocate to the container."
  type        = number
}

variable "container_memory" {
  description = "The memory (in MiB) to allocate to the container."
  type        = number
}

variable "docker_image_url" {
  description = "The URL of the Docker image to deploy."
  type        = string
}

variable "docker_image_tag" {
  description = "The tag of the Docker image to deploy."
  type        = string
}

variable "desired_task_count" {
  description = "The desired number of tasks to run."
  type        = number
}

variable "vpc_id" {
  description = "The ID of the VPC where the resources are deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets."
  type        = list(string)
}

variable "lb_sg_id" {
  description = "The ID of the load balancer's security group."
  type        = string
}

variable "ecs_tasks_sg_id" {
  description = "The ID of the ECS tasks' security group."
  type        = string
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
