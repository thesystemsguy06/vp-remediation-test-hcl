# DMS resources with intentionally non-compliant configurations
# Wave 4 — ~$3-5/day (dms.t3.micro)
#
# Triggered controls:
#   DMS.1  — DMS replication instances should not be public
#   DMS.6  — DMS replication instances should have auto minor version upgrade enabled
#   DMS.7  — DMS replication tasks for target database should have logging enabled
#   DMS.8  — DMS replication tasks for source database should have logging enabled
#   DMS.9  — DMS endpoints should use SSL
#   DMS.10 — DMS endpoints for Neptune should have IAM authorization enabled
#   DMS.12 — DMS endpoints for Redis should have TLS enabled

# DMS replication subnet group
resource "aws_dms_replication_subnet_group" "vp_test" {
  replication_subnet_group_description = "VectorPlane E2E test"
  replication_subnet_group_id          = "vp-test-dms-subnet-group"
  subnet_ids                           = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# DMS replication instance — public, no auto upgrade
resource "aws_dms_replication_instance" "vp_test" {
  replication_instance_class  = "dms.t3.micro"
  replication_instance_id     = "vp-test-insecure-dms"
  replication_subnet_group_id = aws_dms_replication_subnet_group.vp_test.replication_subnet_group_id

  publicly_accessible          = true
  auto_minor_version_upgrade   = false
  multi_az                     = false
  allocated_storage            = 20

  # publicly_accessible = true — triggers DMS.1
  # auto_minor_version_upgrade = false — triggers DMS.6

  tags = var.common_tags
}

# DMS endpoint — no SSL
resource "aws_dms_endpoint" "vp_test_source" {
  endpoint_id   = "vp-test-insecure-source"
  endpoint_type = "source"
  engine_name   = "mysql"

  server_name = "source-db.example.com"
  port        = 3306
  username    = "admin"
  password    = "insecure-password"

  ssl_mode = "none"

  # ssl_mode = "none" — triggers DMS.9

  tags = var.common_tags
}

resource "aws_dms_endpoint" "vp_test_target" {
  endpoint_id   = "vp-test-insecure-target"
  endpoint_type = "target"
  engine_name   = "mysql"

  server_name = "target-db.example.com"
  port        = 3306
  username    = "admin"
  password    = "insecure-password"

  ssl_mode = "none"

  tags = var.common_tags
}
