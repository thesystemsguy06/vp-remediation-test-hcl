# -----------------------------------------------------------------------------
# P0 target — a single S3 bucket for the VectorPlane remediation E2E smoke loop.
#
# The bucket is deliberately COMPLIANT on the common FSBP S3 controls (public
# access blocked, encrypted at rest, TLS-only) EXCEPT versioning: there is no
# aws_s3_bucket_versioning resource, so it fails S3.14
# ("S3 general purpose buckets should have versioning enabled").
#
# That single, deterministic, non-exposing finding is what the P0 loop exercises:
#   deploy -> SecurityHub flags S3.14 -> VP opens a fix PR adding versioning ->
#   merge + apply -> SecurityHub re-evaluates -> PASS.
#
# We intentionally do NOT use a public-access control as the target, so this test
# never creates a publicly accessible bucket.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "p0_target" {
  bucket = "vp-e2e-p0-target-746210888062"
}

# S3.1/S3.2/S3.3/S3.8 — block all public access (compliant)
resource "aws_s3_bucket_public_access_block" "p0_target" {
  bucket                  = aws_s3_bucket.p0_target.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encryption at rest with SSE-S3 (compliant)
resource "aws_s3_bucket_server_side_encryption_configuration" "p0_target" {
  bucket = aws_s3_bucket.p0_target.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3.5 — deny any non-TLS (HTTP) access (compliant)
resource "aws_s3_bucket_policy" "p0_target" {
  bucket = aws_s3_bucket.p0_target.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.p0_target.arn,
        "${aws_s3_bucket.p0_target.arn}/*",
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })

  # Ensure BPA is in place before attaching the policy.
  depends_on = [aws_s3_bucket_public_access_block.p0_target]
}

# NOTE: aws_s3_bucket_versioning is intentionally ABSENT → S3.14 FAIL (P0 target).

output "p0_bucket_name" {
  value = aws_s3_bucket.p0_target.id
}

output "p0_bucket_arn" {
  value = aws_s3_bucket.p0_target.arn
}
