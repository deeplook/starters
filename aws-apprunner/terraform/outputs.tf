output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.app-service.repository_url
}

output "app_service_url" {
  description = "The URL of the App Runner service"
  value       = var.create_apprunner_service ? module.app-service.apprunner_service_url : null
}

output "app_service_name" {
  description = "The name of the App Runner service"
  value       = var.create_apprunner_service ? module.app-service.apprunner_service_name : null
}

output "app_service_arn" {
  description = "The ARN of the App Runner service"
  value       = var.create_apprunner_service ? module.app-service.apprunner_service_arn : null
}
