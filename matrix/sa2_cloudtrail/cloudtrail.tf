# matrix/sa2_cloudtrail — violating CloudTrail trail (+ its S3 bucket & bucket policy)
# authored BARE so a single trail trips MANY SecurityHub controls at once:
#   CloudTrail.1 — is_multi_region_trail OMITTED (=false): not a multi-region trail
#   CloudTrail.2 — kms_key_id OMITTED: no SSE-KMS encryption at rest for log files
#   CloudTrail.3 — no cloud_watch_logs_group_arn: not integrated with CloudWatch Logs
#   CloudTrail.9 — enable_log_file_validation OMITTED (=false): log file validation off
#   S3.22 / S3.23 — no event_selector for S3 object-level write/read data events
# The S3 bucket + bucket policy are companions required for the trail to deploy.

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "trail" {
  bucket        = "vp-sa2-ct-${random_id.s.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.trail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

resource "aws_cloudtrail" "vp" {
  cloud_watch_logs_group_arn = "arn:aws:logs:us-east-1:746210888062:log-group:/vp/companion/856b2431"
  kms_key_id                 = "arn:aws:kms:us-east-1:746210888062:key/8e81be12-deed-4aa9-ad53-51223ba4a09e"
  enable_log_file_validation = true
  name                       = "vp-sa2-${random_id.s.hex}"
  s3_bucket_name             = aws_s3_bucket.trail.id
  enable_logging             = true
  depends_on                 = [aws_s3_bucket_policy.trail]
}
