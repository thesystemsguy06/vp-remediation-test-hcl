# SNS topic with no encryption — triggers SNS.1
resource "aws_sns_topic" "vp_test_notifications" {
  name = "vp-test-notifications"

  # No kms_master_key_id — unencrypted

  tags = merge(local.common_tags, {
    Name = "vp-test-notifications"
  })
}

# SQS queue with no encryption and no DLQ — triggers SQS.1
resource "aws_sqs_queue" "vp_test_work_queue" {
  name = "vp-test-work-queue"

  # No kms_master_key_id — unencrypted
  # No redrive_policy — no DLQ
  visibility_timeout_seconds = 30

  tags = merge(local.common_tags, {
    Name = "vp-test-work-queue"
  })
}
