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

  tags = var.tags
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

  tags = var.tags
}

# Provisions the App Runner service to run the containerized application.
resource "aws_apprunner_service" "app_service" {
  service_name = var.app_service_name

  source_configuration {
    auto_deployments_enabled = true
    image_repository {
      image_configuration {
        port                          = var.app_port
        runtime_environment_variables = var.app_environment_variables
      }
      image_identifier      = var.app_image_identifier
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
  }

  instance_configuration {
    cpu    = var.app_instance_cpu
    memory = var.app_instance_memory
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_autoscale.arn

  health_check_configuration {
    path                = var.app_health_check_path
    interval            = var.app_health_check_interval
    timeout             = var.app_health_check_timeout
    healthy_threshold   = var.app_healthy_threshold
    unhealthy_threshold = var.app_unhealthy_threshold
  }

  tags = var.tags
}
