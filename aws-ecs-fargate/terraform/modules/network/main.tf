# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create a consistent naming prefix for all resources
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

# Look up the VPC, either the default one or a specific one by ID
data "aws_vpc" "selected" {
  id      = var.vpc_id
  default = var.vpc_id == null ? true : false
}

# Get the list of availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# SUBNETS
# ------------------------------------------------------------------------------

# Create two public subnets in different AZs
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Tier = "Public"
  }
}

# ------------------------------------------------------------------------------
# NETWORKING
# ------------------------------------------------------------------------------

# Get the existing Internet Gateway
data "aws_internet_gateway" "gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------

# Security group for the Application Load Balancer
# Allows inbound HTTP traffic from anywhere.
resource "aws_security_group" "lb_sg" {
  name        = "${local.name_prefix}-lb-sg"
  description = "Controls access to the ALB"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-lb-sg"
  }
}

# Security group for the ECS Tasks
# Allows inbound traffic only from the ALB and allows all outbound traffic.
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${local.name_prefix}-tasks-sg"
  description = "Allows inbound traffic from the ALB to the Fargate tasks"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-tasks-sg"
  }
}
