provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AppRunner-E2E"
      ManagedBy   = "Terraform"
      Environment = "Test"
    }
  }
}

module "app-service" {
  source                    = "./modules/app-service"
  ecr_repository_name       = "${var.ecr_repository_name}-${var.environment}"
  image_tag                 = var.image_tag
  app_environment_variables = var.app_environment_variables
  app_service_name          = "${var.app_service_name}-${var.environment}"
  app_autoscale_config_name = "${var.app_autoscale_config_name}-${var.environment}"
  app_max_concurrency       = var.app_max_concurrency
  app_min_size              = var.app_min_size
  app_max_size              = var.app_max_size
  app_port                  = var.app_port
  app_instance_cpu          = var.app_instance_cpu
  app_instance_memory       = var.app_instance_memory
  app_health_check_path     = var.app_health_check_path
  app_health_check_interval = var.app_health_check_interval
  app_health_check_timeout  = var.app_health_check_timeout
  app_healthy_threshold     = var.app_healthy_threshold
  app_unhealthy_threshold   = var.app_unhealthy_threshold
  tags                      = merge(var.common_tags, var.additional_tags)
  environment               = var.environment
}
