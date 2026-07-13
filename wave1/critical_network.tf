# wave1-critical: network layer for the highest-traffic resource types.
# Uses the account's DEFAULT VPC (the region is at its VPC limit), adding only a
# non-compliant security group. us-east-1.
#
# Triggered controls:
#   EC2.19 — security groups should not allow unrestricted access to high-risk ports

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group with unrestricted ingress on admin ports - triggers EC2.19 / EC2.53/54
resource "aws_security_group" "critical_open" {
  name        = "vp-test-critical-open-sg"
  description = "Intentionally over-permissive SG for E2E remediation testing"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH open to the world - non-compliant"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP open to the world - non-compliant"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "vp-test-critical-open-sg", ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}
