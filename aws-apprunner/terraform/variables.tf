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

# tflint-ignore: terraform_unused_declarations
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
  default     = 100
}

variable "app_min_size" {
  description = "The minimum number of instances for the App Runner service."
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "The maximum number of instances for the App Runner service."
  type        = number
  default     = 10
}

variable "app_port" {
  description = "The port the application listens on."
  type        = number
  default     = 3000
}

variable "app_instance_cpu" {
  description = "The CPU units for the App Runner instance (256, 512, 1024, 2048, or 4096)."
  type        = number
  default     = 1024
}

variable "app_instance_memory" {
  description = "The memory in MB for the App Runner instance (512, 1024, 2048, 3072, or 4096)."
  type        = number
  default     = 2048
}

variable "app_health_check_path" {
  description = "The health check path."
  type        = string
  default     = "/"
}

variable "app_health_check_interval" {
  description = "The health check interval in seconds."
  type        = number
  default     = 5
}

variable "app_health_check_timeout" {
  description = "The health check timeout in seconds."
  type        = number
  default     = 2
}

variable "app_healthy_threshold" {
  description = "The number of consecutive successful health checks before marking as healthy."
  type        = number
  default     = 2
}

variable "app_unhealthy_threshold" {
  description = "The number of consecutive failed health checks before marking as unhealthy."
  type        = number
  default     = 5
}

variable "environment" {
  description = "The environment name (e.g., 'prod', 'staging', 'dev')."
  type        = string
  default     = "prod"
}

variable "create_apprunner_service" {
  description = "Whether to create the App Runner service."
  type        = bool
  default     = true
}

variable "app_image_identifier_override" {
  description = "Optional override for the App Runner service image identifier."
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to merge with common tags."
  type        = map(string)
  default     = {}
}
