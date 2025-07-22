# This output will display the public URL of the load balancer after deployment.
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.ecs.load_balancer_dns_name
}
