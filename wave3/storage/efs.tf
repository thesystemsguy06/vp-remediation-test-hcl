# EFS resources with intentionally non-compliant configurations
# Wave 3 — Low cost (~$0.30/GB/mo, $0 if empty)
#
# Triggered controls:
#   EFS.1 — File systems should be configured to encrypt data at rest using KMS
#   EFS.2 — File systems should be in a backup plan
#   EFS.3 — EFS access points should enforce a root directory
#   EFS.4 — EFS access points should enforce a user identity
#   EFS.6 — EFS mount targets should not be associated with a public subnet

# EFS file system — no encryption — triggers EFS.1
resource "aws_efs_file_system" "vp_test" {
  encrypted = false

  # encrypted = false — triggers EFS.1
  # No backup policy — triggers EFS.2

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-unencrypted-efs"
  })
}

# Access point — no root directory, no user identity — triggers EFS.3, EFS.4
resource "aws_efs_access_point" "vp_test" {
  file_system_id = aws_efs_file_system.vp_test.id

  # No root_directory — triggers EFS.3
  # No posix_user — triggers EFS.4

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-open-ap"
  })
}

# Second access point with partial config (root dir but no user)
resource "aws_efs_access_point" "vp_test_partial" {
  file_system_id = aws_efs_file_system.vp_test.id

  root_directory {
    path = "/data"
  }

  # Has root_directory but no posix_user — triggers EFS.4

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-partial-ap"
  })
}
