# EBS resources with intentionally non-compliant configurations
# Wave 3 — Low cost (~$0.10/GB/mo)
#
# Triggered controls:
#   EC2.3  — Attached EBS volumes should be encrypted at-rest
#   EC2.7  — EBS default encryption should be enabled (account-level)
#   EC2.23 — EC2 Transit Gateways should not auto-accept VPC attachment requests

# EBS volume — not encrypted — triggers EC2.3
resource "aws_ebs_volume" "vp_test" {
  availability_zone = "${var.aws_region}a"
  size              = 1
  encrypted         = false

  # encrypted = false — triggers EC2.3

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-unencrypted-vol"
  })
}

# Second EBS volume — also unencrypted, different type
resource "aws_ebs_volume" "vp_test_gp3" {
  availability_zone = "${var.aws_region}a"
  size              = 1
  type              = "gp3"
  encrypted         = false

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-unencrypted-gp3"
  })
}

# EBS default encryption is account-level — uncomment with caution
# resource "aws_ebs_encryption_by_default" "vp_test" {
#   enabled = false
#   # triggers EC2.7
# }
