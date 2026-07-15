# =============================================================================
# Breadth violation matrix — batch 3 (EC2 family: VPC / subnet / instance)
# Networking-enabled so the SG + instance + subnet subcategories can be covered.
# High-confidence CLEAN in-place AUTO fixes only:
#   - aws_subnet   EC2.15  map_public_ip_on_launch = false
#   - aws_instance EC2.8   metadata_options { http_tokens = "required" } (IMDSv2)
# EC2.2 (default SG ingress=[]) is isolated in batch3_sg.tf to de-risk this apply.
# =============================================================================

# Account is at its VPC quota — reuse the existing default VPC via data source.
data "aws_vpc" "vp_ec2" {
  default = true
}

# ---- Subnet: EC2.15 (no auto-assign public IPv4) ----------------------------
resource "aws_subnet" "vp_ec2" {
  vpc_id                  = data.aws_vpc.vp_ec2.id
  cidr_block              = "172.31.128.0/24" # free block in the default VPC
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # EC2.15 violation
  tags                    = { Name = "vp-breadth-subnet-${local.sfx}" }
}

# Latest Amazon Linux 2 AMI (no hardcoded AMI id)
data "aws_ami" "vp_al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ---- Instance: EC2.8 (IMDSv2) -----------------------------------------------
resource "aws_instance" "vp_ec2" {
  ami                         = data.aws_ami.vp_al2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vp_ec2.id
  associate_public_ip_address = false # keep EC2.9 compliant (no public IP)
  # no metadata_options block  -> http_tokens defaults to "optional" -> EC2.8 violation
  tags = { Name = "vp-breadth-ec2-${local.sfx}" }
}

output "breadth_batch3" {
  value = {
    vpc      = data.aws_vpc.vp_ec2.id
    subnet   = aws_subnet.vp_ec2.id
    instance = aws_instance.vp_ec2.id
  }
}
