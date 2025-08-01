output "instance_public_ip" {
  value = aws_instance.main.public_ip
  description = "Public IP address of the EC2 instance"
}

output "private_key_file" {
  value       = local_file.private_key.filename
  description = "Path to the private key file for SSH access"
}
