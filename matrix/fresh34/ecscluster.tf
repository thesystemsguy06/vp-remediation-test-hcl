resource "aws_ecs_cluster" "vp" {
  name = "vp-f34-ecs-${random_id.s.hex}"
}
