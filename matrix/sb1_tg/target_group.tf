# sb1_tg — violating NLB target group (aws_lb_target_group) authored to trip:
#   ELB.21 — TCP/NLB target group health-check / deregistration hygiene
#   ELB.22 — NLB TCP target group should have connection termination enabled
# ELB.22's connection_termination is only valid for NLB (TCP/UDP/TCP_UDP) target
# groups, so protocol must be "TCP". connection_termination is omitted → defaults
# to false, which is the violating state.
resource "aws_lb_target_group" "vp" {
  name        = "vp-sb1-${random_id.s.hex}"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = "vpc-0880cc850def460a5"
  # connection_termination omitted (defaults false) → ELB.22 violation
}
