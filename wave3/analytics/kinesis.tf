# Kinesis resources with intentionally non-compliant configurations
# Wave 3 — ~$0.015/hr per shard (ON_DEMAND mode avoids idle shards)
#
# Triggered controls:
#   Kinesis.1 — Kinesis Data Streams should be encrypted at rest
#   Kinesis.3 — Kinesis streams should have adequate data retention

# Kinesis stream — no encryption — triggers Kinesis.1
resource "aws_kinesis_stream" "vp_test" {
  name = "vp-test-insecure-stream"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  encryption_type = "NONE"
  retention_period = 24

  # encryption_type = "NONE" — triggers Kinesis.1
  # retention_period = 24 (minimum) — may trigger Kinesis.3

  tags = var.common_tags
}

# Kinesis Firehose — no encryption, no logging
# NOTE: Firehose requires a destination. Using S3 with a placeholder.
#
# resource "aws_kinesis_firehose_delivery_stream" "vp_test" {
#   name        = "vp-test-insecure-firehose"
#   destination = "extended_s3"
#
#   extended_s3_configuration {
#     role_arn   = aws_iam_role.vp_test_firehose.arn
#     bucket_arn = "arn:aws:s3:::placeholder-bucket"
#
#     # No encryption — non-compliant
#     # No CloudWatch logging — non-compliant
#   }
#
#   tags = var.common_tags
# }
