# Security Group resources with intentionally non-compliant configurations
# Wave 2 — VPC-dependent, free tier
#
# Triggered controls:
#   EC2.2  — Default VPC SG should not allow inbound/outbound
#   EC2.13 — SGs should not allow ingress from 0.0.0.0/0 to port 22
#   EC2.14 — SGs should not allow ingress from 0.0.0.0/0 to port 3389
#   EC2.18 — SGs should only allow unrestricted incoming traffic for authorized ports
#   EC2.19 — SGs should not allow unrestricted access to high-risk ports
#   EC2.29 — SGs should not allow unrestricted ingress to SSH
#   EC2.51 — VPC endpoint services should have acceptance required enabled

# Web-tier SG — allows SSH from anywhere — triggers EC2.13
resource "aws_security_group" "vp_test_web" {
  name        = "vp-test-web-sg"
  description = "VectorPlane E2E test — intentionally open SSH"
  vpc_id      = aws_vpc.vp_test.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "vp-e2e-test-web-sg"
  })
}

# DB-tier SG — allows RDP and high-risk ports from anywhere
# Triggers EC2.14, EC2.18, EC2.19
resource "aws_security_group" "vp_test_db" {
  name        = "vp-test-db-sg"
  description = "VectorPlane E2E test — intentionally open RDP + DB ports"
  vpc_id      = aws_vpc.vp_test.id

  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB from anywhere"
    from_port   = 27017
    to_port     = 27017
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
    Name = "vp-e2e-test-db-sg"
  })
}

# Admin SG — wide-open ingress — triggers EC2.18, EC2.19
resource "aws_security_group" "vp_test_admin" {
  name        = "vp-test-admin-sg"
  description = "VectorPlane E2E test — intentionally wide open"
  vpc_id      = aws_vpc.vp_test.id

  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 65535
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
    Name = "vp-e2e-test-admin-sg"
  })
}

# IPv6 SG — unrestricted IPv6 ingress — triggers EC2.13 (IPv6 variant)
resource "aws_security_group" "vp_test_ipv6" {
  name        = "vp-test-ipv6-sg"
  description = "VectorPlane E2E test — intentionally open SSH via IPv6"
  vpc_id      = aws_vpc.vp_test.id

  ingress {
    description      = "SSH from anywhere IPv6"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-ipv6-sg"
  })
}
