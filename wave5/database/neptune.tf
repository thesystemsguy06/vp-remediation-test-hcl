# Neptune resources with intentionally non-compliant configurations
# Wave 5 — ~$5-8/day (db.t3.medium)
#
# Triggered controls:
#   Neptune.1 — DB clusters should be encrypted at rest
#   Neptune.2 — DB clusters should publish audit logs to CloudWatch
#   Neptune.3 — DB cluster snapshots should not be public
#   Neptune.4 — DB clusters should have deletion protection enabled
#   Neptune.5 — DB clusters should have automated backups enabled
#   Neptune.6 — DB cluster snapshots should be encrypted at rest
#   Neptune.7 — DB clusters should have IAM database authentication enabled
#   Neptune.8 — DB clusters should be configured to copy tags to snapshots
#   Neptune.9 — DB clusters should be tagged

# Neptune subnet group
resource "aws_neptune_subnet_group" "vp_test" {
  name       = "vp-test-neptune-subnet"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# Neptune cluster — no encryption, no deletion protection, no audit logs
resource "aws_neptune_cluster" "vp_test" {
  cluster_identifier = "vp-test-insecure-neptune"

  neptune_subnet_group_name = aws_neptune_subnet_group.vp_test.name
  storage_encrypted         = false
  deletion_protection       = false
  copy_tags_to_snapshot     = false
  backup_retention_period   = 1
  skip_final_snapshot       = true

  iam_database_authentication_enabled = false

  # storage_encrypted = false — triggers Neptune.1
  # No enable_cloudwatch_logs_exports — triggers Neptune.2
  # deletion_protection = false — triggers Neptune.4
  # backup_retention_period = 1 (no automated backups beyond 1 day) — may trigger Neptune.5
  # iam_database_authentication_enabled = false — triggers Neptune.7
  # copy_tags_to_snapshot = false — triggers Neptune.8

  # Intentionally no tags — triggers Neptune.9
}

# Neptune instance
resource "aws_neptune_cluster_instance" "vp_test" {
  identifier         = "vp-test-insecure-neptune-instance"
  cluster_identifier = aws_neptune_cluster.vp_test.id
  instance_class     = "db.t3.medium"
  engine             = "neptune"

  auto_minor_version_upgrade = false

  tags = var.common_tags
}
