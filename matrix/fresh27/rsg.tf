resource "aws_redshift_subnet_group" "vp" {
  name       = "vp-f27-rsg-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}
