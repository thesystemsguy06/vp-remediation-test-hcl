# ECS Service resources with intentionally non-compliant configurations
# Wave 4 — ~$3-5/day (Fargate)
#
# Triggered controls:
#   ECS.1  — Task definitions should have secure networking modes
#   ECS.2  — ECS services should not have public IPs auto-assigned
#   ECS.3  — Task definitions should not share the host's process namespace
#   ECS.4  — ECS containers should run as non-privileged
#   ECS.5  — ECS containers should be limited to read-only access to root filesystems
#   ECS.8  — Secrets should not be passed as container environment variables
#   ECS.9  — Task definitions should have a logging configuration
#   ECS.10 — Fargate services should run on latest platform version
#   ECS.16 — ECS task sets should not auto-assign public IPs

resource "aws_iam_role" "vp_test_ecs_task" {
  name = "vp-test-ecs-task-role"

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

resource "aws_iam_role" "vp_test_ecs_exec" {
  name = "vp-test-ecs-exec-role"

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

resource "aws_iam_role_policy_attachment" "vp_test_ecs_exec" {
  role       = aws_iam_role.vp_test_ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Insecure task definition — privileged, host PID, secrets in env, no logging
resource "aws_ecs_task_definition" "vp_test_insecure" {
  family                   = "vp-test-insecure-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.vp_test_ecs_exec.arn
  task_role_arn            = aws_iam_role.vp_test_ecs_task.arn

  container_definitions = jsonencode([{
    name      = "insecure-container"
    image     = "public.ecr.aws/nginx/nginx:latest"
    essential = true

    privileged             = false
    readonlyRootFilesystem = false

    environment = [
      {
        name  = "DB_PASSWORD"
        value = "plaintext-secret-for-testing"
      },
      {
        name  = "API_KEY"
        value = "AKIAIOSFODNN7EXAMPLE"
      }
    ]

    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]

    # No logConfiguration — triggers ECS.9
    # readonlyRootFilesystem = false — triggers ECS.5
    # Secrets in environment variables — triggers ECS.8
  }])

  tags = var.common_tags
}

# ECS service — public IP, older platform version
resource "aws_ecs_service" "vp_test" {
  name            = "vp-test-insecure-service"
  cluster         = "vp-test-insecure-cluster"
  task_definition = aws_ecs_task_definition.vp_test_insecure.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  platform_version = "1.3.0"

  network_configuration {
    subnets          = [var.public_subnet_a_id]
    assign_public_ip = true
  }

  # platform_version = "1.3.0" — triggers ECS.10 (should be LATEST)
  # assign_public_ip = true — triggers ECS.2, ECS.16

  tags = var.common_tags
}
