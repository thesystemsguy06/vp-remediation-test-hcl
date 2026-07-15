# =============================================================================
# Breadth violation matrix — batch 6 (EC2: VPC endpoint + network ACL rule)
#   - aws_vpc_endpoint     EC2.60  policy (restrict; no policy = full access)
#   - aws_network_acl_rule EC2.21  cidr_block (0.0.0.0/0 to port 22 -> narrow)
# Both cheap: S3 gateway endpoint is free; NACL + rule are free.
# =============================================================================

# ---- VPC endpoint: EC2.60 (endpoint policy should restrict access) ----------
resource "aws_vpc_endpoint" "vp_ec2" {
  vpc_id       = data.aws_vpc.vp_ec2.id
  service_name = "com.amazonaws.us-east-1.s3"
  # no policy -> default full-access policy -> EC2.60 violation
  tags = { Name = "vp-breadth-vpce-${local.sfx}" }
}

# ---- Network ACL + overly-permissive ingress rule: EC2.21 -------------------
resource "aws_network_acl" "vp_ec2" {
  vpc_id = data.aws_vpc.vp_ec2.id
  tags   = { Name = "vp-breadth-nacl-${local.sfx}" }
}

resource "aws_network_acl_rule" "vp_ec2_ssh" {
  network_acl_id = aws_network_acl.vp_ec2.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/8" # EC2.21 violation (SSH open to world)
  from_port      = 22
  to_port        = 22
}

output "breadth_batch6" {
  value = {
    vpce = aws_vpc_endpoint.vp_ec2.id
    nacl = aws_network_acl.vp_ec2.id
  }
}
