terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Creates an IAM role that the App Runner service will assume to get permissions.
resource "aws_iam_role" "apprunner_role" {
  name = "AppRunnerECRAccessRole-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the AWS-managed policy to the App Runner role, granting it ECR access.
resource "aws_iam_role_policy_attachment" "apprunner_policy_attachment" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Defines the auto-scaling configuration for the App Runner service.
resource "aws_apprunner_auto_scaling_configuration_version" "app_autoscale" {
  auto_scaling_configuration_name = var.app_autoscale_config_name
  max_concurrency                 = var.app_max_concurrency
  min_size                        = var.app_min_size
  max_size                        = var.app_max_size
}

locals {
  # Determine if the provided image is from a public ECR repository.
  is_public_image = strcontains(var.app_image_identifier, "public.ecr.aws")
}

# Provisions the App Runner service to run the containerized application.
resource "aws_apprunner_service" "app_service" {
  service_name                   = var.app_service_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_autoscale.arn

  source_configuration {
    image_repository {
      image_identifier      = var.app_image_identifier
      image_repository_type = local.is_public_image ? "ECR_PUBLIC" : "ECR"
      image_configuration {
        port                          = var.app_port
        runtime_environment_variables = var.app_environment_variables
      }
    }
    authentication_configuration {
      # Only provide an access role for private ECR images.
      access_role_arn = local.is_public_image ? null : aws_iam_role.apprunner_role.arn
    }
    # Auto-deployments only make sense for private ECR images that we control.
    auto_deployments_enabled = local.is_public_image ? false : true
  }

  instance_configuration {
    cpu    = var.app_instance_cpu
    memory = var.app_instance_memory
  }

  health_check_configuration {
    protocol = "HTTP"
    # The public placeholder image responds at '/', not the custom health check path.
    path                = local.is_public_image ? "/" : var.app_health_check_path
    interval            = var.app_health_check_interval
    timeout             = var.app_health_check_timeout
    healthy_threshold   = var.app_healthy_threshold
    unhealthy_threshold = var.app_unhealthy_threshold
  }

  tags = var.app_tags
}
