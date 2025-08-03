variable "aws_region" {
  description = "The AWS region to deploy the resources to."
  type        = string
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "image_tag" {
  description = "The tag of the Docker image in ECR (e.g., 'latest')."
  type        = string
}

variable "docker_build_platform" {
  description = "The target platform for the Docker build (e.g., 'linux/amd64')."
  type        = string
}

variable "app_environment_variables" {
  description = "Environment variables for the App Runner service."
  type        = map(string)
}

variable "app_service_name" {
  description = "The name of the App Runner service."
  type        = string
}

variable "app_autoscale_config_name" {
  description = "The name of the App Runner auto-scaling configuration."
  type        = string
}

variable "app_max_concurrency" {
  description = "The maximum number of concurrent requests per instance."
  type        = number
}

variable "app_min_size" {
  description = "The minimum number of instances for the App Runner service."
  type        = number
}

variable "app_max_size" {
  description = "The maximum number of instances for the App Runner service."
  type        = number
}

variable "app_port" {
  description = "The port the application listens on."
  type        = string
}

variable "app_instance_cpu" {
  description = "The CPU units for the App Runner instance."
  type        = string
}

variable "app_instance_memory" {
  description = "The memory for the App Runner instance."
  type        = string
}

variable "app_health_check_path" {
  description = "The health check path."
  type        = string
}

variable "app_health_check_interval" {
  description = "The health check interval."
  type        = number
}

variable "app_health_check_timeout" {
  description = "The health check timeout."
  type        = number
}

variable "app_healthy_threshold" {
  description = "The healthy threshold for the health check."
  type        = number
}

variable "app_unhealthy_threshold" {
  description = "The unhealthy threshold for the health check."
  type        = number
}

variable "app_tags" {
  description = "Tags for the App Runner service."
  type        = map(string)
}

variable "create_apprunner_service" {
  description = "Whether to create the App Runner service."
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment name to append to resource names (e.g., 'prod', 'staging', 'e2e-test')."
  type        = string
  default     = "prod" # Your main service will be 'prod' by default
}
