output "vpc_id" {
  description = "The ID of the VPC where the resources are deployed."
  value       = data.aws_vpc.selected.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "lb_sg_id" {
  description = "The ID of the load balancer's security group."
  value       = aws_security_group.lb_sg.id
}

output "ecs_tasks_sg_id" {
  description = "The ID of the ECS tasks' security group."
  value       = aws_security_group.ecs_tasks_sg.id
}
