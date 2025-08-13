resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "tf-generated-key-pair-part-2"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/tf-generated-key-pair-part-2.pem"
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
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
docker run -d -p 80:80 nginx
EOF
}
