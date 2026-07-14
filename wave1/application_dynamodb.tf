# DynamoDB resources with intentionally non-compliant configurations
# Wave 1 — Free tier (25 GB free), no VPC dependencies
#
# Triggered controls:
#   DynamoDB.1 — Tables should automatically scale capacity with demand
#   DynamoDB.2 — Tables should have point-in-time recovery enabled
#   DynamoDB.3 — DAX clusters should be encrypted at rest
#   DynamoDB.4 — A table should be present in a backup plan
#   DynamoDB.5 — DynamoDB tables should be tagged
#   DynamoDB.6 — Tables should have deletion protection enabled
#   DynamoDB.7 — DAX clusters should be encrypted in transit

# DynamoDB table — PROVISIONED, no PITR, no deletion protection
resource "aws_dynamodb_table" "vp_test" {
  name         = "vp-test-insecure-table"
  billing_mode = "PROVISIONED"

  read_capacity  = 5
  write_capacity = 5

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Remediated: DynamoDB.6 (deletion protection) + DynamoDB.2 (PITR)
  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  # Still triggers: DynamoDB.1 (no auto-scaling), DynamoDB.4 (no backup plan),
  # DynamoDB.5 (tagging — input_required)

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

data "aws_caller_identity" "current" {}

# Create IAM role for AWS Backup
resource "aws_iam_role" "vp_test_backup_role" {
  name = "vp_test-backup-role"

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
}

# Attach AWS managed policy for DynamoDB backup
resource "aws_iam_role_policy_attachment" "vp_test_backup_policy" {
  role       = aws_iam_role.vp_test_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Create backup vault
resource "aws_backup_vault" "vp_test_backup_vault" {
  name        = "vp_test-backup-vault"
  kms_key_arn = aws_kms_key.vp_test_backup_key.arn

  tags = {
    Name        = "vp_test-backup-vault"
    Environment = "production"
  }
}

# Create KMS key for backup encryption
resource "aws_kms_key" "vp_test_backup_key" {
  description             = "KMS key for vp_test DynamoDB backup vault"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::$${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow AWS Backup to use the key"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create KMS key alias
resource "aws_kms_alias" "vp_test_backup_key_alias" {
  name          = "alias/vp_test-backup-key"
  target_key_id = aws_kms_key.vp_test_backup_key.key_id
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Create backup plan
resource "aws_backup_plan" "vp_test_backup_plan" {
  name = "vp_test-backup-plan"

  rule {
    rule_name         = "vp_test-backup-rule"
    target_vault_name = aws_backup_vault.vp_test_backup_vault.name
    schedule          = "cron(0 2 ? * * *)"

    lifecycle {
      cold_storage_after = 30
      delete_after       = 120
    }

    recovery_point_tags = {
      Environment = "production"
      BackupType  = "scheduled"
    }
  }

  tags = {
    Name        = "vp_test-backup-plan"
    Environment = "production"
  }
}

# Create backup selection
resource "aws_backup_selection" "vp_test_backup_selection" {
  iam_role_arn = aws_iam_role.vp_test_backup_role.arn
  name         = "vp_test-backup-selection"
  plan_id      = aws_backup_plan.vp_test_backup_plan.id

  resources = [
    aws_dynamodb_table.vp_test.arn
  ]

  condition {
    string_equals {
      key   = "aws:ResourceTag/BackupEnabled"
      value = "true"
    }
  }
}

# Add backup tag to DynamoDB table (reference to existing table)
resource "aws_dynamodb_tag" "vp_test_backup_tag" {
  resource_arn = aws_dynamodb_table.vp_test.arn
  key          = "BackupEnabled"
  value        = "true"
}


# DAX IAM role (needed for DAX cluster)
resource "aws_iam_role" "vp_test_dax" {
  name = "vp-test-dax-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "dax.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_iam_role_policy_attachment" "vp_test_dax" {
  role       = aws_iam_role.vp_test_dax.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# DAX cluster — requires VPC subnet group (Wave 2 dependency)
# Uncomment when VPC resources are available
#
# resource "aws_dax_cluster" "vp_test" {
#   cluster_name       = "vp-test-insecure-dax"
#   iam_role_arn       = aws_iam_role.vp_test_dax.arn
#   node_type          = "dax.t3.small"
#   replication_factor = 1
#   subnet_group_name  = "NEEDS_VPC_SUBNET_GROUP"
#
#   server_side_encryption {
#     enabled = false  # DynamoDB.3
#   }
#
#   # No cluster_endpoint_encryption_type — triggers DynamoDB.7
#
#   tags = {
#     ManagedBy = "vectorplane-e2e-test"
#     Wave      = "1"
#   }
# }
