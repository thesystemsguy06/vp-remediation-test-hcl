# ALB/NLB resources with intentionally non-compliant configurations
# Wave 4 — ~$1/day
#
# Triggered controls:
#   ELB.1  — ALB should be configured to redirect HTTP to HTTPS
#   ELB.2  — Classic LBs with SSL/HTTPS listeners should use a predefined security policy
#   ELB.3  — Classic LB listeners should be configured with HTTPS/SSL termination
#   ELB.4  — ALB should be configured to drop invalid HTTP headers
#   ELB.5  — ALB and CLB logging should be enabled
#   ELB.6  — ALB deletion protection should be enabled
#   ELB.7  — Classic LBs should have connection draining enabled
#   ELB.8  — Classic LBs should use SSL certificates
#   ELB.9  — Classic LBs should have cross-zone load balancing enabled
#   ELB.10 — Classic LBs should span multiple AZs
#   ELB.12 — ALBs should have desync mitigation mode configured as defensive or strictest
#   ELB.13 — ALBs, NLBs, and GLBs should span multiple AZs
#   ELB.14 — Classic LBs should have defensive or strictest desync mitigation mode

# ALB — no logging, no deletion protection, no HTTP→HTTPS redirect
resource "aws_lb" "vp_test_alb" {
  name               = "vp-test-insecure-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = []
  subnets            = [var.public_subnet_a_id, var.public_subnet_b_id]

  enable_deletion_protection = false
  drop_invalid_header_fields = false
  desync_mitigation_mode     = "monitor"

  # No access_logs — triggers ELB.5
  # enable_deletion_protection = false — triggers ELB.6
  # drop_invalid_header_fields = false — triggers ELB.4
  # desync_mitigation_mode = "monitor" — triggers ELB.12

  tags = var.common_tags
}

# ALB target group
resource "aws_lb_target_group" "vp_test" {
  name     = "vp-test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

# HTTP listener — no redirect to HTTPS — triggers ELB.1
resource "aws_lb_listener" "vp_test_http" {
  load_balancer_arn = aws_lb.vp_test_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vp_test.arn
  }

  # Forwards HTTP instead of redirecting to HTTPS — triggers ELB.1

  tags = var.common_tags
}

# NLB — single AZ
resource "aws_lb" "vp_test_nlb" {
  name               = "vp-test-insecure-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_a_id]

  enable_deletion_protection = false

  # Single subnet — triggers ELB.13

  tags = var.common_tags
}

# Classic LB — no HTTPS, no logging, no cross-zone, single AZ
resource "aws_elb" "vp_test" {
  name            = "vp-test-insecure-clb"
  subnets         = [var.public_subnet_a_id]
  security_groups = []

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing = false
  connection_draining       = false

  # HTTP only, no HTTPS — triggers ELB.3
  # No access_logs — triggers ELB.5
  # cross_zone_load_balancing = false — triggers ELB.9
  # connection_draining = false — triggers ELB.7
  # Single subnet — triggers ELB.10

  tags = var.common_tags
}
