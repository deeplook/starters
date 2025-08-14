terraform {
  required_version = ">= 1.5.0"
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

module "network" {
  source = "./modules/network"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = var.vpc_id
  container_port = var.container_port
}

resource "aws_ecr_repository" "app" {
  name         = "${var.project_name}-${var.environment}"
  force_delete = true
  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

module "ecs" {
  source = "./modules/ecs"

  aws_region         = var.aws_region
  project_name       = var.project_name
  environment        = var.environment
  container_port     = var.container_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  docker_image_url   = aws_ecr_repository.app.repository_url
  docker_image_tag   = var.docker_image_tag
  desired_task_count = var.autoscale_min_tasks # Start with the minimum number of tasks
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  lb_sg_id           = module.network.lb_sg_id
  ecs_tasks_sg_id    = module.network.ecs_tasks_sg_id

  # Autoscaling parameters
  autoscale_min_tasks  = var.autoscale_min_tasks
  autoscale_max_tasks  = var.autoscale_max_tasks
  autoscale_cpu_target = var.autoscale_cpu_target
}
