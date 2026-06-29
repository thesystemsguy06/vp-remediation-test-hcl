# VPC with NO flow logs — triggers EC2.6
resource "aws_vpc" "vp_test" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "vp-test-vpc"
  })
}

# VPC Flow Log for SecurityHub EC2.6 compliance
resource "aws_flow_log" "vp_test_flow_log" {
  iam_role_arn    = aws_iam_role.vp_test_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vp_test_flow_log_group.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.vp_test.id

  tags = {
    Name = "vp_test-vpc-flow-log"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vp_test_flow_log_group" {
  name              = "/aws/vpc/flowlogs/vp_test"
  retention_in_days = 30

  tags = {
    Name = "vp_test-vpc-flow-log-group"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vp_test_flow_log_role" {
  name = "vp_test-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "vp_test-vpc-flow-log-role"
  }
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vp_test_flow_log_policy" {
  name = "vp_test-vpc-flow-log-policy"
  role = aws_iam_role.vp_test_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


# Subnet with public IP on launch — triggers EC2.15
resource "aws_subnet" "vp_test_public" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "vp-test-public-subnet"
  })
}

# Private subnet — correct configuration for comparison
resource "aws_subnet" "vp_test_private_subnet" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "vp-test-private-subnet"
  })
}

# Internet gateway for the test VPC
resource "aws_internet_gateway" "vp_test_igw" {
  vpc_id = aws_vpc.vp_test.id

  tags = merge(local.common_tags, {
    Name = "vp-test-igw"
  })
}
