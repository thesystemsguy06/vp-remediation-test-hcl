# matrix/fresh17 — Phase-1 free. EFS + bare access point to trip EFS.3 (no root_directory
# enforcement) + EFS.4 (no posix_user). EFS storage empty ~= $0.
resource "aws_efs_file_system" "vp" {
  creation_token = "vp-fresh17-${random_id.s.hex}"
  encrypted      = true
}
resource "aws_efs_access_point" "vp" {
  file_system_id = aws_efs_file_system.vp.id
  # violating: no root_directory (EFS.3), no posix_user (EFS.4)
}
