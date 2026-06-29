# Web SG allowing SSH from anywhere — triggers EC2.2, EC2.13
resource "aws_security_group" "vp_test_web_sg" {
  name        = "vp-test-web-sg"
  description = "Web server security group — intentionally insecure"
  vpc_id      = aws_vpc.vp_test_vpc.id

  ingress {
    description = "SSH from anywhere (insecure)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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

  tags = merge(local.common_tags, {
    Name = "vp-test-web-sg"
  })
}

# DB SG allowing RDP from anywhere and all traffic — triggers EC2.18, EC2.19
resource "aws_security_group" "vp_test_db_sg" {
  name        = "vp-test-db-sg"
  description = "Database security group — intentionally insecure"
  vpc_id      = aws_vpc.vp_test_vpc.id

  ingress {
    description = "RDP from anywhere (insecure)"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "All traffic (insecure)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "vp-test-db-sg"
  })
}

# Default-like SG with all inbound and outbound — triggers EC2.2
resource "aws_security_group" "vp_test_default_sg" {
  name        = "vp-test-default-sg"
  description = "Default-like security group with unrestricted access"
  vpc_id      = aws_vpc.vp_test_vpc.id

  ingress {
    description = "All inbound (insecure)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "vp-test-default-sg"
  })
}
