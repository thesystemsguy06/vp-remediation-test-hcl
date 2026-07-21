# matrix/sa3_subnet — violating subnet in the companion VPC that auto-assigns
# public IPs on launch, tripping:
#   EC2.15 — EC2 subnets should not automatically assign public IP addresses
#   EC2.44 — (subnet public-IP posture) — map_public_ip_on_launch is the checked dimension
# The insecure dimension is map_public_ip_on_launch = true (default is false/secure),
# so the composer's fix is to flip it to false.
resource "aws_subnet" "vp" {
  vpc_id                  = "vpc-0880cc850def460a5"
  cidr_block              = "172.31.200.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "vp-sa3-subnet-${random_id.s.hex}"
  }
}
