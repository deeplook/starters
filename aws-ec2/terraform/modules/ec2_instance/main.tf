

resource "random_id" "key_suffix" {
  byte_length = 4
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.key_name_prefix}-${random_id.key_suffix.hex}"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/${var.key_name_prefix}-${random_id.key_suffix.hex}.pem"
  file_permission = "0400"
}

resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  associate_public_ip_address = true

  # Configure the root volume
  root_block_device {
    volume_size           = var.volume_size # Size in GB (default is often 8 GB)
    volume_type           = "gp3"           # EBS volume type (gp3 is general-purpose SSD)
    delete_on_termination = true            # Delete volume when instance is terminated
  }

  user_data = <<EOF
#!/bin/bash
set -x  # Log commands for debugging

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script..."

# Run commands without set -e to ensure nginx starts even if some commands have non-zero exit
yum update -y || true
amazon-linux-extras install docker -y || true
systemctl start docker || true
systemctl enable docker || true
usermod -a -G docker ec2-user 2>/dev/null || true  # Add ec2-user to docker group (may already exist)

# Ensure docker is running before starting nginx
for i in {1..10}; do
  if systemctl is-active --quiet docker; then
    break
  fi
  echo "Waiting for docker to start..."
  sleep 2
done

docker run -d -p 80:80 nginx || true

echo "User data script completed"
EOF
}
