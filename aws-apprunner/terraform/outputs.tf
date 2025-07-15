output "repository_url" {
  description = "The URL of the ECR repository"
  value       = terraform.workspace == "ecr" ? module.ecr[0].repository_url : null
}

output "apprunner_service_url" {
  description = "The URL of the App Runner service"
  value       = terraform.workspace == "apprunner" ? module.apprunner[0].apprunner_service_url : null
}
