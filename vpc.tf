# VPC with NO flow logs — triggers EC2.6
resource "aws_vpc" "vp_test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "vp-test-vpc"
  })
}

# Subnet with public IP on launch — triggers EC2.15
resource "aws_subnet" "vp_test_public_subnet" {
  vpc_id                  = aws_vpc.vp_test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "vp-test-public-subnet"
  })
}

# Private subnet — correct configuration for comparison
resource "aws_subnet" "vp_test_private_subnet" {
  vpc_id                  = aws_vpc.vp_test_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "vp-test-private-subnet"
  })
}

# Internet gateway for the test VPC
resource "aws_internet_gateway" "vp_test_igw" {
  vpc_id = aws_vpc.vp_test_vpc.id

  tags = merge(local.common_tags, {
    Name = "vp-test-igw"
  })
}
