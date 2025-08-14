# Defines the full image identifier for the application's Docker image.
variable "app_image_identifier" {
  description = "The full URI of the Docker image in ECR (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest)."
  type        = string
  default     = null
}

# Defines the environment variables for the App Runner service.
variable "app_environment_variables" {
  description = "Environment variables for the App Runner service."
  type        = map(string)
  default = {
    NODE_ENV = "production"
  }
}

# Defines the name of the App Runner service.
variable "app_service_name" {
  description = "The name of the App Runner service."
  type        = string
  default     = "node-app-service"
}

# Defines the name of the App Runner auto-scaling configuration.
variable "app_autoscale_config_name" {
  description = "The name of the App Runner auto-scaling configuration."
  type        = string
  default     = "app-autoscale-config"
}

# Defines the maximum number of concurrent requests per instance.
variable "app_max_concurrency" {
  description = "The maximum number of concurrent requests per instance."
  type        = number
  default     = 100
}

# Defines the minimum number of instances for the App Runner service.
variable "app_min_size" {
  description = "The minimum number of instances for the App Runner service."
  type        = number
  default     = 1
}

# Defines the maximum number of instances for the App Runner service.
variable "app_max_size" {
  description = "The maximum number of instances for the App Runner service."
  type        = number
  default     = 10
}

# Defines the port the application listens on.
variable "app_port" {
  description = "The port number that the application listens on. This port will be exposed by the container and used for incoming traffic. Common values: 3000 for Node.js, 8080 for Java, 5000 for Python."
  type        = number
  default     = 3000
}

# Defines the CPU units for the App Runner instance.
variable "app_instance_cpu" {
  description = "The CPU units for the App Runner instance (256, 512, 1024, 2048, or 4096)."
  type        = number
  default     = 1024
}

# Defines the memory for the App Runner instance.
variable "app_instance_memory" {
  description = "The memory in MB for the App Runner instance (512, 1024, 2048, 3072, or 4096)."
  type        = number
  default     = 2048
}

# Defines the health check path.
variable "app_health_check_path" {
  description = "The health check path."
  type        = string
  default     = "/"
}

# Defines the health check interval.
variable "app_health_check_interval" {
  description = "The health check interval in seconds."
  type        = number
  default     = 5
}

# Defines the health check timeout.
variable "app_health_check_timeout" {
  description = "The health check timeout in seconds."
  type        = number
  default     = 2
}

# Defines the healthy threshold for the health check.
variable "app_healthy_threshold" {
  description = "The number of consecutive successful health checks before marking as healthy."
  type        = number
  default     = 2
}

# Defines the unhealthy threshold for the health check.
variable "app_unhealthy_threshold" {
  description = "The number of consecutive failed health checks before marking as unhealthy."
  type        = number
  default     = 5
}

# Defines tags for the App Runner service.
variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The environment name (e.g., 'prod', 'staging', 'dev')."
  type        = string
  default     = "prod"
}
