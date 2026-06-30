# VPC Endpoint resources with intentionally non-compliant configurations
# Wave 2 — VPC-dependent, free tier (Interface endpoints cost ~$0.01/hr)
#
# Triggered controls:
#   EC2.55 — VPC should be configured to use DNS resolution
#   EC2.56 — VPC should be configured to use DNS hostnames  (handled in vpc.tf — enabled)
#   EC2.10 — Amazon EC2 should be configured to use VPC endpoints (existence check)

# Gateway endpoint for S3 — free, tests VPC endpoint configuration
resource "aws_vpc_endpoint" "vp_test_s3" {
  vpc_id       = aws_vpc.vp_test.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  # Gateway endpoints are free
  # VPC endpoint exists but may not have proper policy

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-s3-endpoint"
  })
}

# Gateway endpoint for DynamoDB — free
resource "aws_vpc_endpoint" "vp_test_dynamodb" {
  vpc_id       = aws_vpc.vp_test.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-dynamodb-endpoint"
  })
}

# Interface endpoint for EC2 — costs ~$0.01/hr per AZ
# Uncomment when ready to test (has hourly cost)
#
# resource "aws_vpc_endpoint" "vp_test_ec2" {
#   vpc_id              = aws_vpc.vp_test.id
#   service_name        = "com.amazonaws.${var.aws_region}.ec2"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.vp_test_private_a.id]
#   security_group_ids  = [aws_security_group.vp_test_web.id]
#   private_dns_enabled = true
#
#   tags = merge(var.common_tags, {
#     Name = "vp-e2e-test-ec2-endpoint"
#   })
# }
