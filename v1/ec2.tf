# Web server with IMDSv1 (http_tokens = "optional") and public IP
# — triggers EC2.8, EC2.9
resource "aws_instance" "vp_test_web_server" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vp_test_public.id
  vpc_security_group_ids      = [aws_security_group.vp_test_web.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # monitoring = false (default)

  tags = merge(local.common_tags, {
    Name = "vp-test-web-server"
  })
}

# Bastion with no monitoring and IMDSv1 — triggers EC2.8
resource "aws_instance" "vp_test_bastion" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vp_test_public.id
  vpc_security_group_ids      = [aws_security_group.vp_test_web.id]
  associate_public_ip_address = true

  monitoring = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tags = merge(local.common_tags, {
    Name = "vp-test-bastion"
  })
}
