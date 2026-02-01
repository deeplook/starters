output "instance_public_ip" {
  value       = module.ec2_instance.instance_public_ip
  description = "Public IP of the EC2 instance"
}

output "private_key_file" {
  value       = module.ec2_instance.private_key_file
  description = "Path to the private key file for SSH access"
}

output "ami_id" {
  value       = coalesce(var.ami_id, data.aws_ami.amazon_linux_2.id)
  description = "AMI ID used for the EC2 instance"
}

output "ami_name" {
  value       = data.aws_ami.amazon_linux_2.name
  description = "Name of the Amazon Linux 2 AMI (from data source lookup)"
}
