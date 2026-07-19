# matrix/fresh4 — violating ALB for change-triggered ELB controls (uses default VPC).

resource "aws_security_group" "vp_alb" {
  name        = "vp-fresh4-alb-${random_id.s.hex}"
  description = "vp fresh4 alb sg"
  vpc_id      = "vpc-0880cc850def460a5"
}

# ELB.4 (drop_invalid_header_fields absent=false) + ELB.6 (deletion protection off)
# + ELB.13 (multi-AZ: 2 subnets provided)
resource "aws_lb" "vp_alb" {
  name               = "vp-fresh4-alb-${random_id.s.hex}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vp_alb.id]
  subnets            = ["subnet-0dd7628650cbd31c3", "subnet-0cbeafce2becbdcae"]
}
