# matrix/sc1_docdb — violating DocumentDB cluster authored BARE so one cluster trips
# MANY SecurityHub DocumentDB controls at once:
#   DocumentDB.1 — storage_encrypted = false (encryption at rest disabled)
#   DocumentDB.2 — backup_retention_period = 1 (adequate backups disabled)
#   DocumentDB.3 — (manual snapshots not encrypted / public — cluster-level)
#   DocumentDB.4 — no enabled_cloudwatch_logs_exports (audit logging off)
#   DocumentDB.5 — deletion_protection = false
# Every violating attribute is deliberately set-off / OMITTED so the composer can inject it.

resource "aws_docdb_subnet_group" "vp" {
  name       = "vp-sc1-docdb-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}

resource "aws_docdb_cluster" "vp" {
  cluster_identifier      = "vp-sc1-docdb-${random_id.s.hex}"
  engine                  = "docdb"
  engine_version          = "5.0.0"
  master_username         = "vpadmin"
  master_password         = "VpTest12345Pw"
  db_subnet_group_name    = aws_docdb_subnet_group.vp.name
  vpc_security_group_ids  = ["sg-055114eda16cd94b1"]

  # VIOLATING settings (all deliberately off / omitted):
  storage_encrypted       = false
  deletion_protection     = false
  backup_retention_period = 1
  # no kms_key_id
  # no enabled_cloudwatch_logs_exports (audit/profiler)

  skip_final_snapshot = true
  apply_immediately   = true
}

resource "aws_docdb_cluster_instance" "vp" {
  identifier         = "vp-sc1-docdb-inst-${random_id.s.hex}"
  cluster_identifier = aws_docdb_cluster.vp.id
  instance_class     = "db.t3.medium"
  availability_zone  = "us-east-1d"
  apply_immediately  = true
}
