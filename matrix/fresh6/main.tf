# matrix/fresh6 — self-contained multi-control violating wave.
#
# Centerpiece: a bare aws_lambda_function with NO vpc_config and NO
# dead_letter_config, tripping the "absent-config" Lambda controls
# (Lambda.3 in-a-VPC, Lambda.5 VPC-multi-AZ, Lambda.7 dead-letter).
# Minimal self-contained deps live in this same root: an IAM execution
# role and an inline code zip via the archive provider.
#
# Second resource: a violating aws_ecs_service (Fargate, desired_count=0
# so it is ~free) on the default subnets with assign_public_ip=ENABLED,
# tripping ECS.2 / ECS.16 (public-IP exposure). Its task definition is
# created in this same root.

# ---------------------------------------------------------------------------
# Lambda dependencies (self-contained)
# ---------------------------------------------------------------------------
data "archive_file" "vp_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/index.py"
  output_path = "${path.module}/vp_fresh6_lambda.zip"
}

resource "aws_iam_role" "vp_lambda_exec" {
  name = "vp-fresh6-lambda-exec-${random_id.s.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vp_lambda_basic" {
  role       = aws_iam_role.vp_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Bare Lambda — no vpc_config (Lambda.3 / Lambda.5), no dead_letter_config
# (Lambda.7). Uses a supported runtime so it deploys cleanly.
resource "aws_lambda_function" "vp_fresh6" {
  function_name    = "vp-fresh6-fn-${random_id.s.hex}"
  role             = aws_iam_role.vp_lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.vp_lambda_zip.output_path
  source_code_hash = data.archive_file.vp_lambda_zip.output_base64sha256
}

# ---------------------------------------------------------------------------
# ECS service (violating: assign_public_ip = ENABLED) — desired_count = 0
# ---------------------------------------------------------------------------
resource "aws_ecs_cluster" "vp_fresh6" {
  name = "vp-fresh6-cluster-${random_id.s.hex}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "vp_fresh6" {
  family                   = "vp-fresh6-task-${random_id.s.hex}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([{
    name      = "app"
    image     = "public.ecr.aws/docker/library/busybox:latest"
    essential = true
    command   = ["sleep", "3600"]
  }])
}

resource "aws_ecs_service" "vp_fresh6" {
  name            = "vp-fresh6-svc-${random_id.s.hex}"
  cluster         = aws_ecs_cluster.vp_fresh6.id
  task_definition = aws_ecs_task_definition.vp_fresh6.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0dd7628650cbd31c3", "subnet-0cbeafce2becbdcae"]
    assign_public_ip = false
  }
}
