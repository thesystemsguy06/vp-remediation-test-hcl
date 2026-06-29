# ECS cluster with no Container Insights — triggers ECS.1
resource "aws_ecs_cluster" "vp_test_cluster" {
  name = "vp-test-cluster"

  # No setting block for containerInsights — defaults to disabled

  tags = merge(local.common_tags, {
    Name = "vp-test-cluster"
  })
}
