# =============================================================================
# Breadth violation matrix — batch 3 SG (isolated)
# EC2.2: the VPC default security group should restrict all traffic.
# Isolated in its own file because the fix (sh_ec2_2 -> ingress = []) targets a
# block-type attribute; a live apply here validates whether that renders to
# valid HCL the AWS provider accepts. Kept off batch3.tf's clean instance/subnet
# apply so a surprise here can't block those.
# =============================================================================

resource "aws_default_security_group" "vp_ec2" {
  vpc_id = data.aws_vpc.vp_ec2.id

  # Violating: default SG with an open ingress + egress (EC2.2 wants NONE).
  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
