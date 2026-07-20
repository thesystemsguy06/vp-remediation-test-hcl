resource "aws_ecs_task_definition" "vp" {
  family                = "vp-f24-ecs-${random_id.s.hex}"
  network_mode          = "host"
  container_definitions = jsonencode([{
    name      = "app"
    image     = "nginx:latest"
    cpu       = 128
    memory    = 128
    essential = true
    privileged = true
    environment = [{ name = "DB_PASSWORD", value = "hunter2" }]
  }])
}
