resource "aws_lb_target_group" "vp" {
  name     = "vp-f27-tg-${random_id.s.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0880cc850def460a5"
}
