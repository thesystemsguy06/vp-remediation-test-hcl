resource "aws_efs_file_system" "vp" {
  creation_token = "vp-f25-efs-${random_id.s.hex}"
}
