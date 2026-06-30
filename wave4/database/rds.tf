# RDS resources with intentionally non-compliant configurations
# Wave 4 — ~$5-10/day (db.t3.micro)
#
# Triggered controls:
#   RDS.1  — RDS snapshots should be private
#   RDS.2  — RDS DB instances should prohibit public access
#   RDS.3  — RDS DB instances should have encryption at-rest enabled
#   RDS.4  — RDS cluster snapshots should not be public
#   RDS.5  — RDS DB instances should have multi-AZ enabled
#   RDS.6  — Enhanced monitoring should be configured for RDS instances
#   RDS.7  — RDS clusters should have deletion protection enabled
#   RDS.8  — RDS DB instances should have deletion protection enabled
#   RDS.9  — RDS DB instances should publish logs to CloudWatch
#   RDS.10 — IAM authentication should be configured for RDS instances
#   RDS.11 — RDS instances should have automatic backups enabled
#   RDS.12 — IAM authentication should be configured for RDS clusters
#   RDS.13 — RDS automatic minor version upgrades should be enabled
#   RDS.14 — Amazon Aurora clusters should have backtracking enabled
#   RDS.16 — RDS DB clusters should be configured to copy tags to snapshots
#   RDS.17 — RDS DB instances should be configured to copy tags to snapshots
#   RDS.23 — RDS instances should not use a database engine default port
#   RDS.25 — RDS DB instances should not use public default ports
#   RDS.27 — RDS DB clusters should be encrypted at rest
#   RDS.34 — Aurora MySQL DB clusters should publish audit logs to CloudWatch
#   RDS.35 — RDS DB clusters should have automatic minor version upgrade enabled

# DB subnet group
resource "aws_db_subnet_group" "vp_test" {
  name       = "vp-test-db-subnet-group"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# Security group for RDS
resource "aws_security_group" "vp_test_rds" {
  name        = "vp-test-rds-sg"
  description = "VectorPlane E2E test RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-rds-sg"
  })
}

# RDS instance — intentionally non-compliant on many dimensions
resource "aws_db_instance" "vp_test" {
  identifier     = "vp-test-insecure-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "vptest"
  username = "admin"
  password = "insecure-password-123"

  db_subnet_group_name   = aws_db_subnet_group.vp_test.name
  vpc_security_group_ids = [aws_security_group.vp_test_rds.id]

  publicly_accessible     = true
  multi_az                = false
  storage_encrypted       = false
  deletion_protection     = false
  copy_tags_to_snapshot   = false
  auto_minor_version_upgrade = false
  monitoring_interval     = 0
  iam_database_authentication_enabled = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  port                    = 3306

  # publicly_accessible = true — triggers RDS.2
  # storage_encrypted = false — triggers RDS.3
  # multi_az = false — triggers RDS.5
  # monitoring_interval = 0 — triggers RDS.6
  # deletion_protection = false — triggers RDS.8
  # No enabled_cloudwatch_logs_exports — triggers RDS.9
  # iam_database_authentication_enabled = false — triggers RDS.10
  # backup_retention_period = 0 — triggers RDS.11
  # auto_minor_version_upgrade = false — triggers RDS.13
  # copy_tags_to_snapshot = false — triggers RDS.17
  # Default port 3306 — triggers RDS.23

  tags = var.common_tags
}

# Aurora cluster — no encryption, no deletion protection, no backtracking
resource "aws_rds_cluster" "vp_test" {
  cluster_identifier = "vp-test-insecure-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"
  master_username    = "admin"
  master_password    = "insecure-password-123"

  db_subnet_group_name   = aws_db_subnet_group.vp_test.name
  vpc_security_group_ids = [aws_security_group.vp_test_rds.id]

  storage_encrypted       = false
  deletion_protection     = false
  copy_tags_to_snapshot   = false
  backtrack_window        = 0
  backup_retention_period = 1
  skip_final_snapshot     = true
  iam_database_authentication_enabled = false

  # storage_encrypted = false — triggers RDS.27
  # deletion_protection = false — triggers RDS.7
  # copy_tags_to_snapshot = false — triggers RDS.16
  # backtrack_window = 0 — triggers RDS.14
  # No enabled_cloudwatch_logs_exports — triggers RDS.34
  # iam_database_authentication_enabled = false — triggers RDS.12

  tags = var.common_tags
}

resource "aws_rds_cluster_instance" "vp_test" {
  identifier         = "vp-test-insecure-aurora-instance"
  cluster_identifier = aws_rds_cluster.vp_test.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.vp_test.engine
  engine_version     = aws_rds_cluster.vp_test.engine_version

  auto_minor_version_upgrade = false
  monitoring_interval        = 0

  # auto_minor_version_upgrade = false — triggers RDS.35

  tags = var.common_tags
}
