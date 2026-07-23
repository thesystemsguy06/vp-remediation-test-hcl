# ECS.19: capacity providers should have managed termination protection ENABLED -> set DISABLED
data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "insecure" {
  name_prefix   = "vp-insecure-ecs-cp-b2-"
  image_id      = data.aws_ssm_parameter.al2.value
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "insecure" {
  name                = "vp-insecure-ecs-cp-asg-b2"
  min_size            = 0
  max_size            = 0
  desired_capacity    = 0
  vpc_zone_identifier = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
  launch_template {
    id      = aws_launch_template.insecure.id
    version = "$Latest"
  }
}

resource "aws_ecs_capacity_provider" "insecure" {
  name = "vp-insecure-ecs-cp-b2"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.insecure.arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      status = "DISABLED"
    }
  }
}
