# Network ACL resources with intentionally non-compliant configurations
# Wave 2 — VPC-dependent, free tier
#
# Triggered controls:
#   EC2.21 — NACLs should not allow ingress from 0.0.0.0/0 to port 22 or 3389
#   EC2.16 — Unused NACLs should be removed (default NACL always exists)

# Custom NACL — allows SSH/RDP from anywhere — triggers EC2.21
resource "aws_network_acl" "vp_test" {
  vpc_id     = aws_vpc.vp_test.id
  subnet_ids = [aws_subnet.vp_test_public_a.id]

  # Allow SSH from anywhere — triggers EC2.21
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  # Allow RDP from anywhere — triggers EC2.21
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  # Allow all ephemeral ports inbound (for return traffic)
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow all outbound
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-nacl"
  })
}

# Second NACL — not associated with any subnet — triggers EC2.16
resource "aws_network_acl" "vp_test_unused" {
  vpc_id = aws_vpc.vp_test.id

  # Not associated with any subnet — triggers EC2.16 (unused NACL)

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-unused-nacl"
  })
}
