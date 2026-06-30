# DocumentDB resources with intentionally non-compliant configurations
# Wave 5 — ~$5-8/day (db.t3.medium)
#
# Triggered controls:
#   DocumentDB.1 — Clusters should be encrypted at rest
#   DocumentDB.2 — Clusters should have an adequate backup retention period
#   DocumentDB.3 — Manual cluster snapshots should not be public
#   DocumentDB.4 — Clusters should publish audit logs to CloudWatch
#   DocumentDB.5 — Clusters should have deletion protection enabled

# DocumentDB subnet group
resource "aws_docdb_subnet_group" "vp_test" {
  name       = "vp-test-docdb-subnet"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# DocumentDB cluster — no encryption, no audit logs, no deletion protection
resource "aws_docdb_cluster" "vp_test" {
  cluster_identifier = "vp-test-insecure-docdb"

  db_subnet_group_name = aws_docdb_subnet_group.vp_test.name
  master_username      = "admin"
  master_password      = "insecure-password-123456"

  storage_encrypted       = false
  deletion_protection     = false
  backup_retention_period = 1
  skip_final_snapshot     = true

  # storage_encrypted = false — triggers DocumentDB.1
  # backup_retention_period = 1 — triggers DocumentDB.2 (should be >= 7)
  # No enabled_cloudwatch_logs_exports — triggers DocumentDB.4
  # deletion_protection = false — triggers DocumentDB.5

  tags = var.common_tags
}

resource "aws_docdb_cluster_instance" "vp_test" {
  identifier         = "vp-test-insecure-docdb-instance"
  cluster_identifier = aws_docdb_cluster.vp_test.id
  instance_class     = "db.t3.medium"

  auto_minor_version_upgrade = false

  tags = var.common_tags
}
