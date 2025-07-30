



# Creates an IAM role that the App Runner service will assume to get permissions.
resource "aws_iam_role" "apprunner_role" {
  name = "AppRunnerECRAccessRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
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

# Provisions the App Runner service to run the containerized application.
resource "aws_apprunner_service" "app_service" {
  service_name = var.app_service_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_autoscale.arn

  source_configuration {
    image_repository {
      image_identifier      = var.app_image_identifier != null ? var.app_image_identifier : "public.ecr.aws/aws-containers/hello-app-runner:latest"
      image_repository_type = var.app_image_identifier != null ? "ECR" : "ECR_PUBLIC"
      image_configuration {
        port                            = var.app_port
        runtime_environment_variables = var.app_environment_variables
      }
    }
    authentication_configuration {
      access_role_arn = var.app_image_identifier != null ? aws_iam_role.apprunner_role.arn : null
    }
    auto_deployments_enabled = var.app_image_identifier != null ? true : false
  }

  instance_configuration {
    cpu    = var.app_instance_cpu
    memory = var.app_instance_memory
  }

  health_check_configuration {
    protocol        = "HTTP"
    path            = var.app_health_check_path
    interval        = var.app_health_check_interval
    timeout         = var.app_health_check_timeout
    healthy_threshold   = var.app_healthy_threshold
    unhealthy_threshold = var.app_unhealthy_threshold
  }

  tags = var.app_tags

  depends_on = [
    aws_iam_role_policy_attachment.apprunner_policy_attachment
  ]
}
