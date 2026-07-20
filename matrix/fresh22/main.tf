# fresh22 — input-gated batch (fixes use companion ARNs). Cheap self-contained resources:
#   DynamoDB.1 — table with AWS-owned SSE (should use customer KMS CMK)
#   ECR.1      — repo with image scanning off
#   Kinesis.2  — stream without KMS encryption
resource "aws_dynamodb_table" "vp" {
  deletion_protection_enabled = true
  name                        = "vp-fresh22-${random_id.s.hex}"
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
resource "aws_ecr_repository" "vp" {
  name                 = "vp-fresh22-${random_id.s.hex}"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:746210888062:key/8e81be12-deed-4aa9-ad53-51223ba4a09e"
  }
}
resource "aws_kinesis_stream" "vp" {
  name        = "vp-fresh22-${random_id.s.hex}"
  shard_count = 1
}
