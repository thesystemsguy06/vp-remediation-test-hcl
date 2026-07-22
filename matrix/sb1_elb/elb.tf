# sb1_elb — violating Classic Load Balancer (aws_elb) authored to trip many
# SecurityHub ELB controls at once:
#   ELB.2  — CLB should use HTTPS/SSL (only an HTTP listener present, no SSL cert)
#   ELB.8  — CLB SSL listener should use a predefined security policy (no SSL at all)
#   ELB.9  — CLB should have cross-zone load balancing enabled (set to false)
#   ELB.10 — CLB should span multiple AZs / have connection draining (draining off)
#   ELB.14 — CLB should use defensive/strictest desync mitigation (set to "monitor")
# Every violating attribute is set to an insecure value or omitted.
resource "aws_elb" "vp" {
  name            = "vp-sb1-${random_id.s.hex}"
  subnets         = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
  security_groups = ["sg-055114eda16cd94b1"]

  # HTTP-only listener: no HTTPS/SSL, no ssl_certificate_id.
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

  # Violating settings:
  cross_zone_load_balancing = true
  connection_draining       = true
  desync_mitigation_mode    = "defensive"
  # access_logs block omitted → access logging disabled
}
