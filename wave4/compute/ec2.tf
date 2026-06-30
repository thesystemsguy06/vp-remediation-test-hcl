# EC2 resources with intentionally non-compliant configurations
# Wave 4 — ~$2-5/day (t3.micro)
#
# Triggered controls:
#   EC2.8   — Instances should use IMDSv2
#   EC2.9   — Instances should not have a public IP address
#   EC2.18  — SGs should only allow unrestricted traffic on authorized ports
#   EC2.19  — SGs should not allow unrestricted access to high-risk ports
#   EC2.25  — Launch templates should not assign public IPs
#   EC2.28  — EBS volumes should be covered by a backup plan
#   EC2.170 — Launch templates should use IMDSv2

# Security group for EC2 instances
resource "aws_security_group" "vp_test_ec2" {
  name        = "vp-test-ec2-sg"
  description = "VectorPlane E2E test EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-ec2-sg"
  })
}

# EC2 instance — IMDSv1, public IP, unencrypted root volume
resource "aws_instance" "vp_test" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_a_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vp_test_ec2.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    volume_size = 8
    encrypted   = false
  }

  # http_tokens = "optional" — triggers EC2.8 (should be "required" for IMDSv2)
  # associate_public_ip_address = true — triggers EC2.9
  # root volume not encrypted — triggers EC2.3
  # Not in backup plan — triggers EC2.28

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-instance"
  })
}
