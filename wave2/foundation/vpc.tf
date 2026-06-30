# Foundation VPC resources for Wave 2 VPC-dependent tests
# These provide the shared VPC, subnets, and IGW used by all Wave 2+ resources
#
# Triggered controls:
#   EC2.2  — Default VPC security group should not allow inbound/outbound traffic
#   EC2.6  — VPC flow logging should be enabled
#   EC2.15 — Subnets should not automatically assign public IP addresses
#   EC2.16 — Unused NACLs should be removed
#   EC2.17 — EC2 instances should not use multiple ENIs

# VPC — no flow logs — triggers EC2.6
resource "aws_vpc" "vp_test" {
  cidr_block           = "10.99.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  # No flow logs — triggers EC2.6

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "vp_test" {
  vpc_id = aws_vpc.vp_test.id

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-igw"
  })
}

# Public subnet — auto-assign public IP — triggers EC2.15
resource "aws_subnet" "vp_test_public_a" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.99.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  # map_public_ip_on_launch = true — triggers EC2.15

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-public-a"
  })
}

# Second public subnet (needed for some resources like ALB in Wave 4)
resource "aws_subnet" "vp_test_public_b" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.99.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-public-b"
  })
}

# Private subnet (for resources that should be private)
resource "aws_subnet" "vp_test_private_a" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.99.10.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-private-a"
  })
}

resource "aws_subnet" "vp_test_private_b" {
  vpc_id                  = aws_vpc.vp_test.id
  cidr_block              = "10.99.11.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-private-b"
  })
}

# Route table for public subnets
resource "aws_route_table" "vp_test_public" {
  vpc_id = aws_vpc.vp_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vp_test.id
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-public-rt"
  })
}

resource "aws_route_table_association" "vp_test_public_a" {
  subnet_id      = aws_subnet.vp_test_public_a.id
  route_table_id = aws_route_table.vp_test_public.id
}

resource "aws_route_table_association" "vp_test_public_b" {
  subnet_id      = aws_subnet.vp_test_public_b.id
  route_table_id = aws_route_table.vp_test_public.id
}

# Route table for private subnets (no internet route)
resource "aws_route_table" "vp_test_private" {
  vpc_id = aws_vpc.vp_test.id

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-private-rt"
  })
}

resource "aws_route_table_association" "vp_test_private_a" {
  subnet_id      = aws_subnet.vp_test_private_a.id
  route_table_id = aws_route_table.vp_test_private.id
}

resource "aws_route_table_association" "vp_test_private_b" {
  subnet_id      = aws_subnet.vp_test_private_b.id
  route_table_id = aws_route_table.vp_test_private.id
}

# Default security group — will have default rules — triggers EC2.2
# The default SG is auto-created with the VPC. SecurityHub flags it
# if it allows ANY inbound/outbound traffic. The default SG allows
# all outbound and self-referencing inbound by default.
# We use a data source to reference it for documentation purposes.
data "aws_security_group" "vp_test_default" {
  vpc_id = aws_vpc.vp_test.id
  name   = "default"
}

# Outputs for dependent waves
output "vpc_id" {
  value = aws_vpc.vp_test.id
}

output "public_subnet_a_id" {
  value = aws_subnet.vp_test_public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.vp_test_public_b.id
}

output "private_subnet_a_id" {
  value = aws_subnet.vp_test_private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.vp_test_private_b.id
}
