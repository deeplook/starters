terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "ecr" {
  count = terraform.workspace == "apprunner" ? 1 : 0

  backend = "local"

  config = {
    path = "terraform.tfstate.d/ecr/terraform.tfstate"
  }
}

module "ecr" {
  count = terraform.workspace == "ecr" ? 1 : 0

  source              = "./modules/ecr"
  ecr_repository_name = var.ecr_repository_name
}

module "apprunner" {
  count = terraform.workspace == "apprunner" ? 1 : 0

  source                    = "./modules/apprunner"
  aws_region                = var.aws_region
  app_image_identifier      = terraform.workspace == "apprunner" ? "${data.terraform_remote_state.ecr[0].outputs.repository_url}:${var.image_tag}" : ""
  app_environment_variables = var.app_environment_variables
  app_service_name          = var.app_service_name
  app_autoscale_config_name = var.app_autoscale_config_name
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
  app_tags                  = var.app_tags
}
