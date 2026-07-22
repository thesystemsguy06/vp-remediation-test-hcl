# matrix/sc1_aurora — violating Aurora MySQL cluster authored BARE so one cluster
# trips MANY SecurityHub RDS controls at once:
#   RDS.2  — publicly_accessible instance (public access to DB)
#   RDS.12 — (IAM database authentication disabled)
#   RDS.13 — auto minor version upgrade / no automated backups (backup_retention_period=1)
#   RDS.16 — cluster copy_tags_to_snapshot disabled
#   RDS.19 — no enabled_cloudwatch_logs_exports (log exports off)
#   RDS.34/35 (Aurora) — storage_encrypted=false / deletion_protection=false
# Every violating attribute is deliberately set-off / OMITTED so the composer can inject it.

resource "aws_db_subnet_group" "vp" {
  name       = "vp-sc1-aurora-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}

resource "aws_rds_cluster" "vp" {
  cluster_identifier   = "vp-sc1-aurora-${random_id.s.hex}"
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.08.2"
  master_username      = "vpadmin"
  master_password      = "VpTest12345Pw"
  db_subnet_group_name = aws_db_subnet_group.vp.name
  vpc_security_group_ids = ["sg-055114eda16cd94b1"]

  # VIOLATING settings (all deliberately off / omitted):
  storage_encrypted               = false
  deletion_protection             = false
  backup_retention_period         = 1
  copy_tags_to_snapshot           = false
  iam_database_authentication_enabled = false
  # no kms_key_id
  # no enabled_cloudwatch_logs_exports

  skip_final_snapshot = true
  apply_immediately   = true
}

resource "aws_rds_cluster_instance" "vp" {
  identifier           = "vp-sc1-aurora-inst-${random_id.s.hex}"
  cluster_identifier   = aws_rds_cluster.vp.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.vp.engine
  engine_version       = aws_rds_cluster.vp.engine_version
  db_subnet_group_name = aws_db_subnet_group.vp.name
  availability_zone    = "us-east-1d"
  publicly_accessible  = true
  apply_immediately    = true
}
