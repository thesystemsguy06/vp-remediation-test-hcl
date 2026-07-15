# =============================================================================
# Breadth violation matrix — batch 1
# Each resource is deployed in a MAXIMALLY-VIOLATING state so that the
# corresponding VP auto-fixable remediation snippet is exercised end-to-end
# (deploy -> SH finding -> campaign fix -> apply -> SH PASS).
# Cheap, no-VPC resources only. Suffix "b1" keeps names predictable.
# =============================================================================

locals {
  sfx = "b1-a1f4"
}

# ---- EFS: EFS.1 (encrypt at rest), EFS.2 (automatic backups) ----------------
resource "aws_efs_file_system" "vp_efs" {
  creation_token = "vp-breadth-efs-${local.sfx}"
  encrypted      = true # EFS.1 violation
  # no aws_efs_backup_policy companion -> EFS.2 violation
}

# ---- DynamoDB: DynamoDB.2 (PITR), DynamoDB.6 (deletion protection) ----------
resource "aws_dynamodb_table" "vp_ddb" {
  deletion_protection_enabled = true
  name                        = "vp-breadth-ddb-${local.sfx}"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "id"

  attribute {
    name = "id"
    type = "S"
  }
  # no point_in_time_recovery block -> DynamoDB.2 violation
  # deletion_protection_enabled defaults false -> DynamoDB.6 violation

  point_in_time_recovery {
    enabled = true
  }
}

# ---- ECR: ECR.1 (scan on push), ECR.2 (tag immutability), ECR.3 (lifecycle) -
resource "aws_ecr_repository" "vp_ecr" {
  name                 = "vp-breadth-ecr-${local.sfx}"
  image_tag_mutability = "IMMUTABLE" # ECR.2 violation

  image_scanning_configuration {
    scan_on_push = false # ECR.1 violation
  }
  # no aws_ecr_lifecycle_policy companion -> ECR.3 violation
}

# ---- Kinesis: Kinesis.1 (server-side encryption) ----------------------------
resource "aws_kinesis_stream" "vp_kinesis" {
  encryption_type  = "KMS"
  kms_key_id       = "alias/aws/kinesis"
  name             = "vp-breadth-kinesis-${local.sfx}"
  shard_count      = 1
  retention_period = 168
  # no encryption_type -> Kinesis.1 violation (defaults to NONE)
}

# ---- KMS: KMS.4 (key rotation) ----------------------------------------------
resource "aws_kms_key" "vp_kms" {
  description             = "vp-breadth-kms-${local.sfx}"
  enable_key_rotation     = true # KMS.4 violation
  deletion_window_in_days = 7
}

# ---- SQS: SQS.1 (encryption at rest) ----------------------------------------
resource "aws_sqs_queue" "vp_sqs" {
  name                    = "vp-breadth-sqs-${local.sfx}"
  sqs_managed_sse_enabled = false # SQS.1 violation
}

# ---- SNS: SNS.1 (encryption at rest) ----------------------------------------
resource "aws_sns_topic" "vp_sns" {
  kms_master_key_id = "alias/aws/sns"
  name              = "vp-breadth-sns-${local.sfx}"
  # no kms_master_key_id -> SNS.1 violation
}

# ---- Cognito: Cognito.3 (strong password policy) ----------------------------
resource "aws_cognito_user_pool" "vp_cognito" {
  mfa_configuration   = "ON"
  user_pool_tier      = "PLUS"
  deletion_protection = "ACTIVE"
  name                = "vp-breadth-cognito-${local.sfx}"

  password_policy {
    minimum_length    = 8 # Cognito.3 violation (weak policy)
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  software_token_mfa_configuration {
    enabled = true
  }
}

# ---- CloudWatch Log Group: retention / KMS ----------------------------------
resource "aws_cloudwatch_log_group" "vp_lg" {
  name = "/vp/breadth/${local.sfx}/loggroup"
  # no retention_in_days, no kms_key_id
}

output "breadth_batch1" {
  value = {
    efs      = aws_efs_file_system.vp_efs.id
    ddb      = aws_dynamodb_table.vp_ddb.name
    ecr      = aws_ecr_repository.vp_ecr.name
    kinesis  = aws_kinesis_stream.vp_kinesis.name
    kms      = aws_kms_key.vp_kms.key_id
    sqs      = aws_sqs_queue.vp_sqs.name
    sns      = aws_sns_topic.vp_sns.name
    cognito  = aws_cognito_user_pool.vp_cognito.id
    loggroup = aws_cloudwatch_log_group.vp_lg.name
  }
}
