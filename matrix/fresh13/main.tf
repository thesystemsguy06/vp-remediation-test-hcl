# matrix/fresh13 — Tier-1 FREE config-only violating resources (zero running cost),
# batched to trip several deterministic SecurityHub controls at once:
#   AutoScaling.3  — launch config metadata_options http_tokens = "optional" (IMDSv2 off)
#   AutoScaling.5  — launch config associate_public_ip_address = true
#   CloudWatch.16  — log group has no retention_in_days (never expires)
#   S3.1 / S3.3    — bare S3 bucket with NO aws_s3_bucket_public_access_block
# Deploying + SH scoring needs no GitHub; the campaign PR does. Prepped during the
# GitHub outage so the whole backlog campaigns the moment writes recover.

# NOTE: AutoScaling.3/5 target aws_launch_configuration, which AWS no longer permits
# creating in new accounts ("not available in your account — use launch templates").
# Those two controls are untestable live here (launch configs are AWS-deprecated).

# CloudWatch.16 — no retention_in_days set
resource "aws_cloudwatch_log_group" "vp" {
  name = "/vp/fresh13/${random_id.s.hex}"
}

# S3.1 / S3.3 — bare bucket, no public access block sub-resource
resource "aws_s3_bucket" "vp" {
  bucket        = "vp-fresh13-${random_id.s.hex}"
  force_destroy = true
}
