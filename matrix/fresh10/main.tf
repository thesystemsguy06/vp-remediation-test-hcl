# matrix/fresh10 — violating ECS task definition authored to trip several
# SecurityHub ECS controls at once (task-def revision only, zero running cost):
#   ECS.1  — network_mode = "bridge" (not the secure awsvpc mode)
#   ECS.3  — pid_mode = "host" (shares the host's process namespace)
#   ECS.8  — secrets (AWS keys) passed as plaintext container environment vars
#   ECS.17 — network_mode = "bridge" (host/bridge networking)
# ECS.18 (EFS transit encryption) is intentionally excluded — its snippet is
# disabled (fabricated fs-12345678, fabricated-reference bug class).

resource "aws_ecs_task_definition" "vp" {
  family                   = "vp-fresh10-${random_id.s.hex}"
  network_mode             = "bridge"
  pid_mode                 = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "app"
    image     = "nginx:latest"
    essential = true
    environment = [
      { name = "AWS_ACCESS_KEY_ID", value = "AKIAEXAMPLE1234567" },
      { name = "AWS_SECRET_ACCESS_KEY", value = "examplesecretkey0000000000000000" }
    ]
  }])
}
