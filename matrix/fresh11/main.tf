# matrix/fresh11 — violating EC2 launch template authored to trip several
# SecurityHub EC2 launch-template controls at once (all config-only, zero running cost):
#   EC2.25  — network_interfaces assigns a public IP (associate_public_ip_address = true)
#   EC2.170 — metadata_options does NOT require IMDSv2 (http_tokens = "optional")
#   EC2.181 — block_device_mappings EBS volume is NOT encrypted (encrypted = false)
# Each violating attribute is deliberately set to the insecure value so the composer
# can strengthen it in place.

resource "aws_launch_template" "vp" {
  name          = "vp-fresh11-${random_id.s.hex}"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t3.micro"

  # EC2.170: IMDSv2 not enforced
  metadata_options {
    http_tokens = "required"
  }

  # EC2.25: interface auto-assigns a public IP
  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
  }

  # EC2.181: root EBS volume unencrypted
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted   = false
      volume_size = 8
    }
  }
}
