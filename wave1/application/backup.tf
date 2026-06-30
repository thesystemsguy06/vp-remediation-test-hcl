# AWS Backup resources with intentionally non-compliant configurations
# Wave 1 — Free tier (vault is free, backup storage has costs), no VPC dependencies
#
# Triggered controls:
#   Backup.1 — Vault not encrypted with KMS CMK
#   Backup.2 — No lifecycle/cross-region copy in backup plan
#   Backup.3 — Vault has no access policy

# Backup vault — no KMS, no access policy — triggers Backup.1, Backup.3
resource "aws_backup_vault" "vp_test" {
  name = "vp-e2e-test-backup-vault"

  # No kms_key_arn — uses default encryption — triggers Backup.1
  # No aws_backup_vault_policy — triggers Backup.3

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Backup plan — no lifecycle, no cross-region copy — triggers Backup.2
resource "aws_backup_plan" "vp_test" {
  name = "vp-e2e-test-backup-plan"

  rule {
    rule_name         = "vp-e2e-daily-backup"
    target_vault_name = aws_backup_vault.vp_test.name
    schedule          = "cron(0 12 * * ? *)"

    # No lifecycle block — triggers Backup.5
    # No copy_action block — triggers Backup.2
  }

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}
