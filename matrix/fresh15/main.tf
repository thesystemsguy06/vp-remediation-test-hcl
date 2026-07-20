# matrix/fresh15 — Phase-1. Real EC2 instance (t3.micro, ~$0.01/hr, torn down after) to trip:
#   EC2.8  — metadata_options http_tokens = "optional" (IMDSv2 not required)
#   (a bare instance may also trip EC2.17 / EBS-encryption controls — observe what fires)
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "vp" {
  ami           = data.aws_ami.al2.id
  instance_type = "t3.micro"

  metadata_options {
    http_tokens = "required" # EC2.8: IMDSv2 not enforced
  }

  tags = { Name = "vp-fresh15-${random_id.s.hex}" }
}
