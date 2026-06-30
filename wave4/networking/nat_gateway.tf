# NAT Gateway resources
# Wave 4 — ~$1.50/day + data processing
#
# Triggered controls:
#   EC2.10 — Amazon EC2 should be configured to use VPC endpoints (cost optimization)
#
# NAT Gateways don't have many direct SecurityHub controls,
# but they're needed for private subnet internet access in testing.

resource "aws_eip" "vp_test_nat" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-nat-eip"
  })
}

resource "aws_nat_gateway" "vp_test" {
  allocation_id = aws_eip.vp_test_nat.id
  subnet_id     = var.public_subnet_a_id

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-nat-gw"
  })
}
