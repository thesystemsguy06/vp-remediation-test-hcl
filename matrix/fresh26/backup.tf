resource "aws_backup_vault" "vp" { name = "vp-f26-bv-${random_id.s.hex}" }
resource "aws_backup_plan" "vp" {
  name = "vp-f26-bp-${random_id.s.hex}"
  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.vp.name
    schedule          = "cron(0 5 * * ? *)"
  }
}
