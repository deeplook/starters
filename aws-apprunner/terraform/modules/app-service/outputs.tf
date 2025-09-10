# Outputs the publicly accessible URL for the deployed App Runner service.
output "apprunner_service_url" {
  description = "The default URL of the App Runner service."
  value       = var.create_apprunner_service ? aws_apprunner_service.app_service[0].service_url : null
}

output "apprunner_service_name" {
  description = "The name of the App Runner service."
  value       = var.create_apprunner_service ? aws_apprunner_service.app_service[0].service_name : null
}

output "apprunner_service_arn" {
  description = "The ARN of the App Runner service."
  value       = var.create_apprunner_service ? aws_apprunner_service.app_service[0].arn : null
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}
