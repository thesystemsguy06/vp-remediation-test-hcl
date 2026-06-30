# RDS subnet group for test instances
resource "aws_db_subnet_group" "vp_test_db_subnet_group" {
  name       = "vp-test-db-subnet-group"
  subnet_ids = [aws_subnet.vp_test_private_subnet.id, aws_subnet.vp_test_public.id]

  tags = merge(local.common_tags, {
    Name = "vp-test-db-subnet-group"
  })
}

# Payments DB — publicly accessible, no encryption, no multi-AZ, no monitoring,
# no deletion protection, no log exports — triggers RDS.2, RDS.3, RDS.5, RDS.6, RDS.8, RDS.9
resource "aws_db_instance" "vp_test_payments_db" {
  identifier        = "vp-test-payments-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "payments"
  username = "admin"
  password = "insecure_password_123!"

  db_subnet_group_name   = aws_db_subnet_group.vp_test_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.vp_test_db.id]

  publicly_accessible     = true
  storage_encrypted       = false
  multi_az                = false
  deletion_protection     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  auto_minor_version_upgrade = false

  # No enhanced monitoring (monitoring_interval = 0 is default)
  # No CloudWatch log exports

  tags = merge(local.common_tags, {
    Name = "vp-test-payments-db"
  })
}

# Analytics DB — no encryption, no backup retention, no auto minor version upgrade
resource "aws_db_instance" "vp_test_analytics_db" {
  identifier        = "vp-test-analytics-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "analytics"
  username = "admin"
  password = "insecure_password_456!"

  db_subnet_group_name   = aws_db_subnet_group.vp_test_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.vp_test_db.id]

  storage_encrypted          = false
  backup_retention_period    = 0
  auto_minor_version_upgrade = false
  skip_final_snapshot        = true
  deletion_protection        = false

  tags = merge(local.common_tags, {
    Name = "vp-test-analytics-db"
  })
}
