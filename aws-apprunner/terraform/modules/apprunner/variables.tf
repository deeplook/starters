# Specifies the AWS region where all resources will be deployed.
variable "aws_region" {
  description = "The AWS region to deploy the resources to."
  type        = string
  default     = "eu-central-1"
}



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
  default     = 80
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
  description = "The port the application listens on."
  type        = string
  default     = "3000"
}

# Defines the CPU units for the App Runner instance.
variable "app_instance_cpu" {
  description = "The CPU units for the App Runner instance."
  type        = string
  default     = "512"
}

# Defines the memory for the App Runner instance.
variable "app_instance_memory" {
  description = "The memory for the App Runner instance."
  type        = string
  default     = "1024"
}

# Defines the health check path.
variable "app_health_check_path" {
  description = "The health check path."
  type        = string
  default     = "/health"
}

# Defines the health check interval.
variable "app_health_check_interval" {
  description = "The health check interval."
  type        = number
  default     = 20
}

# Defines the health check timeout.
variable "app_health_check_timeout" {
  description = "The health check timeout."
  type        = number
  default     = 10
}

# Defines the healthy threshold for the health check.
variable "app_healthy_threshold" {
  description = "The healthy threshold for the health check."
  type        = number
  default     = 2
}

# Defines the unhealthy threshold for the health check.
variable "app_unhealthy_threshold" {
  description = "The unhealthy threshold for the health check."
  type        = number
  default     = 5
}

# Defines tags for the App Runner service.
variable "app_tags" {
  description = "Tags for the App Runner service."
  type        = map(string)
  default = {
    Name = "NodeAppService"
  }
}

variable "environment" {
  description = "The environment name (e.g., 'prod', 'e2e-test')."
  type        = string
  default     = "prod"
}
