# CloudWatch resources with insecure/missing configurations
# Wave 1 — Free tier, no VPC dependencies

variable "common_tags_monitoring" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Log group with no KMS encryption, no retention — triggers CloudWatch.1-16 (bundle controls)
# The absence of metric filters + alarms IS the non-compliant state for CloudWatch.1-16.
# VP remediation creates the metric filter + alarm as TOPOLOGY_BUNDLE resources.
resource "aws_cloudwatch_log_group" "vp_test" {
  name = "/vp-test/e2e-insecure"
  # No kms_key_id — triggers CloudWatch.2 (log group encryption)
  # No retention_in_days — never expires

  tags = var.common_tags_monitoring
}

# Second log group to test retention-specific controls
resource "aws_cloudwatch_log_group" "vp_test_no_retention" {
  name = "/vp-test/e2e-no-retention"
  # No retention_in_days set — defaults to Never Expire

  tags = var.common_tags_monitoring
}

# EventBridge event bus — no resource policy, no tags — triggers EventBridge.2, EventBridge.3
resource "aws_cloudwatch_event_bus" "vp_test" {
  name = "vp-test-insecure-bus"

  tags = var.common_tags_monitoring
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_bus_policy" "vp_test_policy" {
  event_bus_name = aws_cloudwatch_event_bus.vp_test.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "events:PutEvents"
        ]
        Resource = aws_cloudwatch_event_bus.vp_test.arn
      }
    ]
  })
}


# Note: aws_cloudwatch_metric_alarm and aws_cloudwatch_log_metric_filter are
# BUNDLE resources — VP remediation CREATES them as new resources.
# Their absence IS the non-compliant state for CloudWatch.1, 3-16.
# Controls covered by bundle creation:
#   CloudWatch.1  — unauthorized API calls metric filter + alarm
#   CloudWatch.3  — root account usage metric filter + alarm
#   CloudWatch.4  — IAM policy changes
#   CloudWatch.5  — CloudTrail config changes
#   CloudWatch.6  — console auth failures
#   CloudWatch.7  — CMK disable/delete
#   CloudWatch.8  — S3 bucket policy changes
#   CloudWatch.9  — Config changes
#   CloudWatch.10 — security group changes
#   CloudWatch.11 — NACL changes
#   CloudWatch.12 — network gateway changes
#   CloudWatch.13 — route table changes
#   CloudWatch.14 — VPC changes
