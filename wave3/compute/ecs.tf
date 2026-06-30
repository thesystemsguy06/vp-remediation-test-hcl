# ECS resources with intentionally non-compliant configurations
# Wave 3 — ECS cluster is free, task definitions are free
#
# Triggered controls:
#   ECS.12 — ECS clusters should use Container Insights
#   ECS.10 — ECS Fargate services should run on latest platform version
#   ECS.16 — ECS task sets should not auto-assign public IP addresses

# ECS cluster — no Container Insights — triggers ECS.12
resource "aws_ecs_cluster" "vp_test" {
  name = "vp-test-insecure-cluster"

  # No setting block with containerInsights — triggers ECS.12

  tags = var.common_tags
}

# ECS task definition — for use in Wave 4 services
resource "aws_ecs_task_definition" "vp_test" {
  family                   = "vp-test-insecure-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "test-container"
    image     = "public.ecr.aws/nginx/nginx:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/vp-test"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = var.common_tags
}

# Task execution role
resource "aws_iam_role" "vp_test_ecs_execution" {
  name = "vp-test-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_ecs_execution" {
  role       = aws_iam_role.vp_test_ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
