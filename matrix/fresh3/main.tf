# matrix/fresh3 — violating resources for net-new controls on NEW cheap types.
# Dependency-free, cheap, oracle-verified FIXED before deploy.

# ECS.12 — cluster without Container Insights enabled
resource "aws_ecs_cluster" "vp_ecs_cluster" {
  name = "vp-fresh3-ecs-${random_id.s.hex}"
}

# SNS — topic without encryption / hardening (catches net-new SNS controls)
resource "aws_sns_topic" "vp_sns" {
  name = "vp-fresh3-sns-${random_id.s.hex}"
}

# Backup vault — no KMS encryption (catches net-new Backup controls)
resource "aws_backup_vault" "vp_backup" {
  name = "vp-fresh3-backup-${random_id.s.hex}"
}

# Glue catalog database (catches net-new Glue controls)
resource "aws_glue_catalog_database" "vp_glue_db" {
  name = "vp_fresh3_glue_${random_id.s.hex}"
}
