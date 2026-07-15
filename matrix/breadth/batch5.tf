# =============================================================================
# Breadth violation matrix — batch 5 (SG-narrowing + tags INPUT classes)
# A custom SG with world-open SSH (22) + RDP (3389), untagged. Exercises the
# input-gated families:
#   - EC2.13  narrow_ingress ingress/22  (input: allowed_cidr_blocks)
#   - EC2.14  narrow_ingress ingress/3389 (input: allowed_cidr_blocks)
#   - EC2.43  tags on the SG              (input: tags)
# Validates that supplying inputs turns these from MANUAL_REVIEW into a real fix.
# =============================================================================

resource "aws_security_group" "vp_sg" {
  name        = "vp-breadth-sg-${local.sfx}"
  description = "vp breadth SG for EC2.13/14/43"
  vpc_id      = data.aws_vpc.vp_ec2.id

  ingress {
    description = "SSH open to world (EC2.13 violation)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "RDP open to world (EC2.14 violation)"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # no tags -> EC2.43 violation
}

output "breadth_batch5" {
  value = { sg = aws_security_group.vp_sg.id }
}
