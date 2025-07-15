

# Outputs the publicly accessible URL for the deployed App Runner service.
output "apprunner_service_url" {
  description = "The default URL of the App Runner service."
  value       = aws_apprunner_service.app_service.service_url
}