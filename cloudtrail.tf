# S3 bucket for CloudTrail logs (minimal, no security controls)
resource "aws_s3_bucket" "vp_test_cloudtrail_bucket" {
  bucket = "vp-test-cloudtrail-logs-e2e-insecure"

  tags = merge(local.common_tags, {
    Name = "vp-test-cloudtrail-bucket"
  })
}

resource "aws_s3_bucket_policy" "vp_test_cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.vp_test_cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.vp_test_cloudtrail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.vp_test_cloudtrail_bucket.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail with no KMS encryption, no log file validation, no CloudWatch Logs,
# not multi-region — triggers CloudTrail.2, CloudTrail.4, CloudTrail.5
resource "aws_cloudtrail" "vp_test_trail" {
  name                          = "vp-test-trail"
  s3_bucket_name                = aws_s3_bucket.vp_test_cloudtrail_bucket.id
  is_multi_region_trail         = false
  enable_log_file_validation    = false
  include_global_service_events = false

  # No cloud_watch_logs_group_arn — no CloudWatch integration
  # No kms_key_id — no encryption

  tags = merge(local.common_tags, {
    Name = "vp-test-trail"
  })

  depends_on = [aws_s3_bucket_policy.vp_test_cloudtrail_bucket_policy]
}
