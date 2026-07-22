# matrix/sd1_efs — bare EFS file system (encrypted=true so it deploys) with NO companion
# aws_efs_backup_policy and NO file system policy, so it trips:
#   EFS.2 — EFS volumes should be in backup plans / automatic backups enabled
#   EFS.3/EFS.4 — EFS access points / file systems should enforce a policy (no policy present)
# The composer's fix provisions an aws_efs_backup_policy (backup_policy { status = "ENABLED" })
# and/or an aws_efs_file_system_policy.
resource "aws_efs_file_system" "vp" {
  creation_token = "vp-sd1-efs-${random_id.s.hex}"
  encrypted      = true
}
