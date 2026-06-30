# Elastic IP resources with intentionally non-compliant configurations
# Wave 2 — VPC-dependent, free tier (if associated; unassociated EIPs cost $0.005/hr)
#
# Triggered controls:
#   EC2.12 — Unused EIPs should be removed

# Unassociated EIP — triggers EC2.12
resource "aws_eip" "vp_test" {
  domain = "vpc"

  # Not associated with any instance or ENI — triggers EC2.12

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-unused-eip"
  })
}
