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

# IAM role for AWS Backup service
resource "aws_iam_role" "critical_backup_role" {
  name = "critical-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "critical-backup-role"
    Purpose = "SecurityHub-RDS-26-Compliance"
  }
}

# Attach AWS managed policy for backup service
resource "aws_iam_role_policy_attachment" "critical_backup_policy" {
  role       = aws_iam_role.critical_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Attach AWS managed policy for restores
resource "aws_iam_role_policy_attachment" "critical_backup_restore_policy" {
  role       = aws_iam_role.critical_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# AWS Backup vault
resource "aws_backup_vault" "critical_backup_vault" {
  name        = "critical-backup-vault"
  kms_key_arn = aws_kms_key.critical_backup_key.arn

  tags = {
    Name    = "critical-backup-vault"
    Purpose = "SecurityHub-RDS-26-Compliance"
  }
}

# KMS key for backup encryption
resource "aws_kms_key" "critical_backup_key" {
  description             = "KMS key for critical backup encryption"
  deletion_window_in_days = 7

  tags = {
    Name    = "critical-backup-key"
    Purpose = "SecurityHub-RDS-26-Compliance"
  }
}

# KMS key alias
resource "aws_kms_alias" "critical_backup_key_alias" {
  name          = "alias/critical-backup-key"
  target_key_id = aws_kms_key.critical_backup_key.key_id
}

# AWS Backup plan
resource "aws_backup_plan" "critical_backup_plan" {
  name = "critical-backup-plan"

  rule {
    rule_name         = "critical-daily-backup-rule"
    target_vault_name = aws_backup_vault.critical_backup_vault.name
    schedule          = "cron(0 5 ? * * *)"
    start_window      = 480
    completion_window = 10080

    recovery_point_tags = {
      Name    = "critical-backup"
      Purpose = "SecurityHub-RDS-26-Compliance"
    }

    lifecycle {
      cold_storage_after = 30
      delete_after       = 120
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.critical_backup_vault.arn
      lifecycle {
        cold_storage_after = 30
        delete_after       = 120
      }
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  tags = {
    Name    = "critical-backup-plan"
    Purpose = "SecurityHub-RDS-26-Compliance"
  }
}

# AWS Backup selection
resource "aws_backup_selection" "critical_backup_selection" {
  iam_role_arn = aws_iam_role.critical_backup_role.arn
  name         = "critical-backup-selection"
  plan_id      = aws_backup_plan.critical_backup_plan.id

  resources = [
    aws_db_instance.critical.arn
  ]

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupEnabled"
    value = "true"
  }

  condition {
    string_equals {
      key   = "aws:ResourceTag/Environment"
      value = "production"
    }
  }
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
