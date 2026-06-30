# SNS and SQS resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   SNS.1 — Topics should be encrypted at-rest using KMS
#   SNS.2 — Logging of delivery status should be enabled
#   SNS.3 — SNS topics should be tagged
#   SNS.4 — Topic access policy should not allow public access
#   SQS.1 — Queues should be encrypted at rest using KMS
#   SQS.2 — SQS queues should be tagged

variable "common_tags_messaging" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# SNS topic — no KMS, no tags — triggers SNS.1, SNS.3
resource "aws_sns_topic" "vp_test" {
  name = "vp-test-insecure-topic"
  # No kms_master_key_id — triggers SNS.1
  # No tags — triggers SNS.3
}

# Overly permissive topic policy — triggers SNS.4
resource "aws_sns_topic_policy" "vp_test" {
  arn = aws_sns_topic.vp_test.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowPublicPublish"
      Effect    = "Allow"
      Principal = "*"
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.vp_test.arn
    }]
  })
}

# SQS queue — no KMS, no tags — triggers SQS.1, SQS.2
resource "aws_sqs_queue" "vp_test" {
  name = "vp-test-insecure-queue"
  # No kms_master_key_id — triggers SQS.1
  # No tags — triggers SQS.2
}

# Dead letter queue — also no KMS — triggers SQS.1
resource "aws_sqs_queue" "vp_test_dlq" {
  name = "vp-test-insecure-dlq"
  # No kms_master_key_id — triggers SQS.1
  # No tags — triggers SQS.2
}
