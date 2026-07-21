# matrix/sa2_backup — violating AWS Backup vault + plan authored BARE:
#   Backup.2 — aws_backup_vault has NO kms_key_arn (falls back to AWS-owned key,
#              not a customer-managed CMK → recovery points not CMK-encrypted)
#   Backup.5 — backup plan rule is weak: no lifecycle (no defined retention) and
#              enable_continuous_backup OMITTED (=false → no point-in-time recovery)

resource "aws_backup_vault" "vp" {
  name = "vp-sa2-${random_id.s.hex}"
}

resource "aws_backup_plan" "vp" {
  name = "vp-sa2-plan-${random_id.s.hex}"

  rule {
    rule_name         = "vp-weak-rule"
    target_vault_name = aws_backup_vault.vp.name
    schedule          = "cron(0 5 * * ? *)"
  }
}
