# =============================================================================
# L3 S3 pilot — purpose-built VIOLATING buckets.
# Each bucket carries a subset of S3 findings; in aggregate they exercise the
# S3 crown-jewel snippets end-to-end (deploy -> SH finding -> VP remediate ->
# PR -> apply -> SH PASS). See docs/testing/L3_E2E_COVERAGE_MAP.md.
# Nothing here is "secure by omission" — violations are explicit so SH scores
# them reliably rather than relying on account defaults.
# =============================================================================

resource "random_id" "s" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# bare — no SSL policy, public-access-block all FALSE, no logging/versioning/
# lifecycle. Targets: S3.5 (SSL), S3.8 (block public access), S3.9 (access
# logging), S3.13 (lifecycle), S3.14 (versioning).
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "bare" {
  bucket        = "vp-l3-s3-bare-${random_id.s.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bare_versioning" {
  bucket = aws_s3_bucket.bare.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_logging" "bare_logging" {
  bucket = aws_s3_bucket.bare.id

  target_bucket = aws_s3_bucket.bare.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_policy" "bare_ssl" {
  bucket = aws_s3_bucket.bare.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bare.arn,
          "${aws_s3_bucket.bare.arn}/*"
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


resource "aws_s3_bucket_lifecycle_configuration" "bare_lifecycle" {
  bucket = aws_s3_bucket.bare.id

  rule {
    id     = "vp-default-lifecycle"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


# Explicit all-false PAB → definitively violates S3.8 (don't rely on account BPA).
resource "aws_s3_bucket_public_access_block" "bare" {
  bucket                  = aws_s3_bucket.bare.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# versioned_nolifecycle — versioning ON but NO lifecycle. Targets S3.10
# (versioned buckets must have a lifecycle policy) — only violatable when
# versioning is enabled, which is why it needs its own bucket.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "versioned" {
  bucket        = "vp-l3-s3-versioned-${random_id.s.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "versioned_lifecycle" {
  bucket = aws_s3_bucket.versioned.id

  rule {
    id     = "vp-default-lifecycle"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


resource "aws_s3_bucket_versioning" "versioned" {
  bucket = aws_s3_bucket.versioned.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# replication — plain bucket with no cross-region replication and no CMK SSE.
# Targets S3.7 (CRR) and S3.17 (KMS CMK encryption). Both TIER-B — the pilot
# confirms whether SH scores them.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "replication" {
  bucket        = "vp-l3-s3-replication-${random_id.s.hex}"
  force_destroy = true
}

output "l3_s3_buckets" {
  value = {
    bare        = aws_s3_bucket.bare.bucket
    versioned   = aws_s3_bucket.versioned.bucket
    replication = aws_s3_bucket.replication.bucket
  }
}
