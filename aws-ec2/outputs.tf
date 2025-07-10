output "instance_public_ip" {
  value       = module.ec2_instance.instance_public_ip
  description = "Public IP of the EC2 instance"
}

output "private_key_file" {
  value       = module.ec2_instance.private_key_file
  description = "Path to the private key file for SSH access"
}
