# =============================================================================
# Breadth violation matrix — batch 4 (EC2 family, cheap AUTO resource types)
# Reuses batch3's default-VPC subnet + AL2 AMI data source (same root).
#   - aws_network_interface  EC2.180  source_dest_check = true
#   - aws_launch_template    EC2.170  metadata_options http_tokens = "required"
#   - aws_launch_template    EC2.25   network_interfaces associate_public_ip_address = false
#   - aws_launch_template    EC2.181  block_device_mappings ebs.encrypted (nested; may manual_review)
#   - aws_instance (public)  EC2.9    associate_public_ip_address = false
# =============================================================================

# ---- ENI: EC2.180 (source/dest check) ---------------------------------------
resource "aws_network_interface" "vp_ec2" {
  subnet_id         = aws_subnet.vp_ec2.id
  source_dest_check = false # EC2.180 violation
  tags              = { Name = "vp-breadth-eni-${local.sfx}" }
}

# ---- Launch template: EC2.170 / EC2.25 / EC2.181 ----------------------------
resource "aws_launch_template" "vp_ec2" {
  name          = "vp-breadth-lt-${local.sfx}"
  image_id      = data.aws_ami.vp_al2.id
  instance_type = "t3.micro"

  metadata_options {
    http_tokens = "optional" # EC2.170 violation (not IMDSv2)
  }

  network_interfaces {
    associate_public_ip_address = true # EC2.25 violation
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted = false # EC2.181 violation
    }
  }
}

# ---- Instance with public IP: EC2.9 -----------------------------------------
resource "aws_instance" "vp_ec2_pub" {
  ami                         = data.aws_ami.vp_al2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vp_ec2.id
  associate_public_ip_address = true # EC2.9 violation (has public IP)

  metadata_options {
    http_tokens = "required" # keep EC2.8 compliant here
  }

  tags = { Name = "vp-breadth-ec2pub-${local.sfx}" }
}

output "breadth_batch4" {
  value = {
    eni      = aws_network_interface.vp_ec2.id
    lt       = aws_launch_template.vp_ec2.id
    instance = aws_instance.vp_ec2_pub.id
  }
}
