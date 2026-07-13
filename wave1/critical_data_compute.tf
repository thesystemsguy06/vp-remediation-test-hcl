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
  identifier     = "vp-test-critical-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  username       = "vpadmin"
  password       = "ChangeMe-E2E-Test-1234!" # test-only; not a real secret
  allocated_storage = 20

  db_subnet_group_name = aws_db_subnet_group.critical.name
  vpc_security_group_ids = [aws_security_group.critical_open.id]

  # Intentionally non-compliant:
  publicly_accessible          = true  # RDS.2
  deletion_protection          = false # RDS.8
  backup_retention_period      = 0     # RDS.11
  auto_minor_version_upgrade   = false # RDS.13
  copy_tags_to_snapshot        = false # RDS.17
  storage_encrypted            = false # RDS.3 (replacement-required)
  iam_database_authentication_enabled = false # RDS.10
  # No enabled_cloudwatch_logs_exports — RDS.9

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
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]

  metadata_options {
    http_tokens = "optional" # EC2.8 — should be "required" (IMDSv2)
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
