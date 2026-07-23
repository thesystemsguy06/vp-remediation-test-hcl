resource "aws_lb" "vp_b3" {
  name               = "vp-b3-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["sg-055114eda16cd94b1"]
  subnets            = ["subnet-0dd7628650cbd31c3","subnet-0a0a41f888339dd65"]
}
resource "aws_lb_target_group" "vp_b3" {
  name        = "vp-b3-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0880cc850def460a5"
  target_type = "ip"
}
resource "aws_lb_listener" "vp_b3" {
  load_balancer_arn = aws_lb.vp_b3.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vp_b3.arn
  }
}
