# CloudTrail resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   CloudTrail.1 — Should be enabled with multi-Region trail
#   CloudTrail.2 — Should have encryption at-rest enabled
#   CloudTrail.4 — Log file validation should be enabled
#   CloudTrail.5 — Should be integrated with CloudWatch Logs
#   CloudTrail.6 — S3 bucket for logs should not be publicly accessible
#   CloudTrail.7 — S3 bucket should have access logging enabled

data "aws_caller_identity" "current_ct" {}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "vp_test_cloudtrail" {
  bucket        = "vp-e2e-test-cloudtrail-${random_id.ct_suffix.hex}"
  force_destroy = true

  tags = var.common_tags_monitoring

  lifecycle_rule {
    enabled = true
    id      = "cleanup"
    expiration {
      days = 90

    }
  }
}

resource "aws_s3_bucket_logging" "vp_test_cloudtrail_logging" {
  bucket = aws_s3_bucket.vp_test_cloudtrail.id

  target_bucket = aws_s3_bucket.vp_test_cloudtrail.id
  target_prefix = "access-logs/"
}


resource "random_id" "ct_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "vp_test_cloudtrail" {
  bucket = aws_s3_bucket.vp_test_cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.vp_test_cloudtrail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.vp_test_cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current_ct.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail — single-region, no KMS, no log validation, no CloudWatch
resource "aws_cloudtrail" "vp_test" {
  name                       = "vp-test-insecure-trail"
  s3_bucket_name             = aws_s3_bucket.vp_test_cloudtrail.id
  is_multi_region_trail      = false
  enable_log_file_validation = true

  # No kms_key_id — triggers CloudTrail.2
  # Single-region — triggers CloudTrail.1
  # No log validation — triggers CloudTrail.4
  # No cloud_watch_logs_group_arn — triggers CloudTrail.5

  tags = var.common_tags_monitoring

  depends_on = [aws_s3_bucket_policy.vp_test_cloudtrail]
}
