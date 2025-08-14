terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create a consistent naming prefix for all resources
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

# Create a log group to store container logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/ecs/${local.name_prefix}"

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

# Create an Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "main" {
  name_prefix = "tg-"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ------------------------------------------------------------------------------
# ECS CLUSTER
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

# ------------------------------------------------------------------------------
# IAM Role that ECS Tasks can assume
# ------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-task-exec-role"

  # Trust policy allowing ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-task-exec-role"
  }
}

# Attach the AWS managed policy for ECS task execution to the role
# This policy grants permissions to pull images from ECR and send logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ------------------------------------------------------------------------------
# ECS TASK DEFINITION
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "main" {
  family                   = "${local.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # This is the definition of the container to run
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-container"
      image     = "${var.docker_image_url}:${var.docker_image_tag}"
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-task"
  }
}

# ------------------------------------------------------------------------------
# ECS SERVICE
# ------------------------------------------------------------------------------

resource "aws_ecs_service" "main" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  # Ensure service waits for ALB to be ready before starting
  depends_on = [aws_lb_listener.http]

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = true # Required for Fargate tasks to pull images from public repos
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${local.name_prefix}-container"
    container_port   = var.container_port
  }

  # This helps prevent downtime during deployments
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Name = "${local.name_prefix}-service"
  }
}

# ------------------------------------------------------------------------------
# AUTOSCALING
# ------------------------------------------------------------------------------

# Define the scalable target for App Auto Scaling
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = var.autoscale_max_tasks
  min_capacity       = var.autoscale_min_tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Define the scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${local.name_prefix}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscale_cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300 # Cooldown period (in seconds) before scaling in
    scale_out_cooldown = 60  # Cooldown period (in seconds) before scaling out
  }
}
