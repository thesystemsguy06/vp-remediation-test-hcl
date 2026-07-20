# fresh22 — input-gated batch (fixes use companion ARNs). Cheap self-contained resources:
#   DynamoDB.1 — table with AWS-owned SSE (should use customer KMS CMK)
#   ECR.1      — repo with image scanning off
#   Kinesis.2  — stream without KMS encryption
resource "aws_dynamodb_table" "vp" {
  name         = "vp-fresh22-${random_id.s.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
resource "aws_ecr_repository" "vp" {
  name                 = "vp-fresh22-${random_id.s.hex}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_kinesis_stream" "vp" {
  name        = "vp-fresh22-${random_id.s.hex}"
  shard_count = 1
}
