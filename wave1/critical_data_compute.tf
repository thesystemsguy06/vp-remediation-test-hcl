# wave1-critical: the highest-value data + compute resources.
# RDS carries the largest snippet set in the catalog (34), so it is the priority
# for E2E validation. All intentionally non-compliant.

# ─── RDS ─────────────────────────────────────────────────────────────────────
# Triggered controls (config-change, in-place remediable):
#   RDS.2  — DB instances should not be publicly accessible
#   RDS.8  — DB instances should have deletion protection enabled
#   RDS.9  — DB instances should publish logs to CloudWatch
#   RDS.11 — DB instances should have automatic backups enabled
#   RDS.13 — RDS automatic minor version upgrades should be enabled
#   RDS.17 — RDS should be configured to copy tags to snapshots
#   RDS.10 — IAM authentication should be configured
# Replacement-required (advisory gate, NOT auto-applied):
#   RDS.3  — DB instances should have encryption at rest enabled

resource "aws_db_subnet_group" "critical" {
  name       = "vp-test-critical-subnets"
  subnet_ids = slice(data.aws_subnets.default.ids, 0, 2)
  tags       = { ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}

resource "aws_db_instance" "critical" {
  monitoring_interval = 60
  monitoring_role_arn = "arn:aws:iam::746210888062:role/vp-rds-monitoring-role"
  multi_az            = true
  identifier          = "vp-test-critical-db"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  username            = "vpadmin"
  password            = "ChangeMe-E2E-Test-1234!" # test-only; not a real secret
  allocated_storage   = 20

  db_subnet_group_name   = aws_db_subnet_group.critical.name
  vpc_security_group_ids = [aws_security_group.critical_open.id]

  # REMEDIATED to match VP snippet renders (in-place controls):
  publicly_accessible        = false # RDS.2  (sh_rds_2)
  deletion_protection        = true  # RDS.8  (sh_rds_8)
  backup_retention_period    = 7     # RDS.11 (sh_rds_11)
  auto_minor_version_upgrade = true  # RDS.13 (sh_rds_13)
  copy_tags_to_snapshot      = true  # RDS.17 (sh_rds_17)
  # multi_az (RDS.5) deferred — AWS InsufficientDBInstanceCapacity in this AZ (environmental, not a snippet issue). Render is correct: multi_az = true.
  iam_database_authentication_enabled = true                      # RDS.10 (sh_rds_10)
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"] # RDS.9/RDS.36 (sh_rds_6/enable_cloudwatch_log_exports)
  # storage_encrypted stays false — RDS.3 is replacement-required (advisory, migrate_rds_encryption playbook)
  storage_encrypted = false # RDS.3 (NOT auto-remediated by design)

  skip_final_snapshot = true
  apply_immediately   = true

  tags = { Name = "vp-test-critical-db", ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}

# ─── EBS volume ──────────────────────────────────────────────────────────────
# EC2.3 — EBS volumes should be encrypted at rest (replacement-required advisory)
resource "aws_ebs_volume" "critical" {
  availability_zone = "us-east-1a"
  size              = 1
  encrypted         = false # EC2.3

  tags = { Name = "vp-test-critical-vol", ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}

# ─── EC2 instance ────────────────────────────────────────────────────────────
# Triggered controls:
#   EC2.8  — EC2 instances should use IMDSv2  (http_tokens = optional)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "critical" {
  associate_public_ip_address = false
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]

  metadata_options {
    http_tokens = "required" # EC2.8 — REMEDIATED to IMDSv2 (ensure_set http_tokens)
  }

  tags = { Name = "vp-test-critical-ec2", ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}

# ─── Lambda ──────────────────────────────────────────────────────────────────
# Triggered controls:
#   Lambda.5 — VPC Lambda functions should operate in multiple AZs (single subnet)
#   (Lambda.2 runtime is validated at render-level; kept compliant-runtime here)
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_critical" {
  name               = "vp-test-critical-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = { ManagedBy = "vectorplane-e2e-test" }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/.build/lambda_critical.zip"
  source {
    content  = "def handler(event, context):\n    return {'ok': True}\n"
    filename = "index.py"
  }
}

resource "aws_lambda_function" "critical" {
  function_name    = "vp-test-critical-fn"
  role             = aws_iam_role.lambda_critical.arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = { Name = "vp-test-critical-fn", ManagedBy = "vectorplane-e2e-test", Wave = "1" }
}
