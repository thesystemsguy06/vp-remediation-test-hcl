# matrix/fresh12 — violating RDS db_instance (db.t3.micro, cheapest) authored to trip
# several in-place-remediable SecurityHub RDS controls at once:
#   RDS.17 — copy_tags_to_snapshot = false
#   RDS.30 — auto_minor_version_upgrade = false
#   RDS.42 — no enabled_cloudwatch_logs_exports (audit logging off)
#   RDS.46 — publicly_accessible = true
# RDS.3/RDS.4 (storage_encrypted) also fire but are ForceNew → the Step-5c replacement
# gate routes them to advisory (verified), so no destructive apply. multi_az left at the
# default (false); RDS.5 may fire but its fix is cost-doubling so it's a campaign-time choice.

resource "aws_db_instance" "vp" {
  identifier                 = "vp-fresh12-${random_id.s.hex}"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  username                   = "vpadmin"
  password                   = "ChangeMe123456"
  storage_encrypted          = false
  publicly_accessible        = true
  copy_tags_to_snapshot      = false
  auto_minor_version_upgrade = false
  skip_final_snapshot        = true
  deletion_protection        = false
  apply_immediately          = true
}
