output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "app_service_url" {
  description = "The URL of the App Runner service"
  value       = var.create_apprunner_service ? module.apprunner[0].apprunner_service_url : null
}

output "app_service_name" {
  description = "The name of the App Runner service"
  value       = var.create_apprunner_service ? module.apprunner[0].apprunner_service_name : null
}

output "app_service_arn" {
  description = "The ARN of the App Runner service"
  value       = var.create_apprunner_service ? module.apprunner[0].apprunner_service_arn : null
}
