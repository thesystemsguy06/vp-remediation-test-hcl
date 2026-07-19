# matrix/fresh5 — violating CLASSIC ELB (aws_elb) in the default VPC. Authored BARE
# so a single classic Load Balancer trips MANY SecurityHub ELB controls at once:
#   ELB.2  — internet-facing classic LB has no ACM/HTTPS cert (ssl_certificate_id absent)
#   ELB.3  — classic LB listeners not all HTTPS/SSL (connection_draining/secure-transport absent)
#   ELB.7  — connection draining disabled (connection_draining absent)
#   ELB.8  — SSL security policy weak/absent (ssl_security_policy absent)
#   ELB.9  — cross-zone load balancing disabled (cross_zone_load_balancing absent)
#   ELB.10 — not spanning multiple AZs by config (availability_zones absent)
#   ELB.14 — desync mitigation mode not defensive/strictest (desync_mitigation_mode absent)
# Every one of these attributes is deliberately OMITTED so the composer can inject them.

resource "aws_security_group" "vp_elb" {
  name        = "vp-fresh5-elb-${random_id.s.hex}"
  description = "vp fresh5 classic elb sg"
  vpc_id      = "vpc-0880cc850def460a5"
}

resource "aws_elb" "vp_classic" {
  connection_draining = true
  name                = "vp-fresh5-elb-${random_id.s.hex}"
  internal            = false
  subnets             = ["subnet-0dd7628650cbd31c3", "subnet-0cbeafce2becbdcae"]
  security_groups     = [aws_security_group.vp_elb.id]

  # HTTP-only listener: no HTTPS, no SSL cert, no SSL policy.
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
}
