# matrix/fresh1 — purpose-built VIOLATING resources (security block ABSENT) so VP
# generates a real fix. Cheap / free, in-place-remediable, no-input controls.
# Each resource is intentionally non-compliant for the tagged SecurityHub control(s).

# SQS.1 — queue not encrypted at rest (no sqs_managed_sse_enabled / kms)
resource "aws_sqs_queue" "vp_sqs" {
  name = "vp-fresh1-sqs-${random_id.s.hex}"
}

# Kinesis.1 (no server-side encryption) + Kinesis.3 (retention < 168h; default 24)
resource "aws_kinesis_stream" "vp_kinesis" {
  retention_period = 168
  encryption_type  = "KMS"
  kms_key_id       = "alias/aws/kinesis"
  name             = "vp-fresh1-kinesis-${random_id.s.hex}"
  shard_count      = 1
}

# ECR.1 (no scan-on-push) + ECR.2 (tag mutability = MUTABLE by default)
resource "aws_ecr_repository" "vp_ecr" {
  image_tag_mutability = "IMMUTABLE"
  name                 = "vp-fresh1-ecr-${random_id.s.hex}"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:746210888062:key/16c15ba7-402c-43d0-ba11-329276ef2ece"
  }
}

# DynamoDB.2 (no server_side_encryption block) + DynamoDB.6 (deletion protection off)
resource "aws_dynamodb_table" "vp_dynamodb" {
  deletion_protection_enabled = true
  name                        = "vp-fresh1-ddb-${random_id.s.hex}"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "id"
  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

# CloudWatch.16 — log group with no retention (never expires)
resource "aws_cloudwatch_log_group" "vp_cwlg" {
  name = "/vp/fresh1/${random_id.s.hex}"
}

# KMS.4 — customer key with rotation disabled (default)
resource "aws_kms_key" "vp_kms" {
  enable_key_rotation = true
  description         = "vp-fresh1-kms-${random_id.s.hex}"
}

# Athena.4 — workgroup without enforced configuration
resource "aws_athena_workgroup" "vp_athena" {
  name = "vp-fresh1-athena-${random_id.s.hex}"
}
