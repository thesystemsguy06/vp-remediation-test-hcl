# S3 resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   S3.1   — Block public access settings enabled
#   S3.2   — Prohibit public read access
#   S3.3   — Prohibit public write access
#   S3.5   — Require SSL for requests
#   S3.8   — Block public access at bucket level
#   S3.9   — Server access logging enabled
#   S3.10  — Versioned buckets should have lifecycle policies
#   S3.11  — Event notifications enabled
#   S3.13  — Lifecycle configurations
#   S3.14  — Versioning enabled
#   S3.19  — Access points should have block public access
#   S3.20  — MFA delete enabled

variable "common_tags_storage" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Primary test bucket
resource "aws_s3_bucket" "vp_test_data" {
  bucket = "vp-e2e-test-data-${random_id.suffix.hex}"
  tags   = var.common_tags_storage
}

resource "aws_s3_bucket_lifecycle_configuration" "vp_test_data_lifecycle" {
  bucket = aws_s3_bucket.vp_test_data.id

  rule {
    id     = "vp-default-lifecycle"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


resource "aws_s3_bucket_logging" "vp_test_data_logging" {
  bucket = aws_s3_bucket.vp_test_data.id

  target_bucket = aws_s3_bucket.vp_test_data.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_policy" "vp_test_data_ssl" {
  bucket = aws_s3_bucket.vp_test_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.vp_test_data.arn,
          "${aws_s3_bucket.vp_test_data.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}


resource "random_id" "suffix" {
  byte_length = 4
}

# Versioning suspended — triggers S3.14
resource "aws_s3_bucket_versioning" "vp_test_data" {
  bucket = aws_s3_bucket.vp_test_data.id
  versioning_configuration {
    status = "Suspended"
  }
}

# All public access block settings false — triggers S3.1, S3.8
resource "aws_s3_bucket_public_access_block" "vp_test_data" {
  bucket = aws_s3_bucket.vp_test_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# No bucket policy enforcing SSL — triggers S3.5
# No server access logging — triggers S3.9
# No lifecycle rules — triggers S3.13
# No event notifications — triggers S3.11

# Second bucket for logging/cross-reference tests
resource "aws_s3_bucket" "vp_test_logs" {
  bucket = "vp-e2e-test-logs-${random_id.suffix.hex}"
  tags   = var.common_tags_storage
}

resource "aws_s3_bucket_public_access_block" "vp_test_logs" {
  bucket = aws_s3_bucket.vp_test_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Access point with public access enabled — triggers S3.19
resource "aws_s3_access_point" "vp_test" {
  bucket = aws_s3_bucket.vp_test_data.id
  name   = "vp-test-public-ap"

  public_access_block_configuration {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }
}
