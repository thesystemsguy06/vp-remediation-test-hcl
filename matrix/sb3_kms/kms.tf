resource "aws_kms_key" "this" {
  description         = "vp-sb3-kms-${random_id.s.hex}"
  enable_key_rotation = false
}
