# S3 bucket with NO versioning, NO encryption, NO public access block,
# NO server access logging, NO SSL enforcement — triggers S3.1, S3.5, S3.8, S3.9
resource "aws_s3_bucket" "vp_test_data" {
  bucket = "vp-test-data-bucket-e2e-insecure"

  tags = merge(local.common_tags, {
    Name = "vp-test-data-bucket"
  })
}

# Log bucket with NO versioning, NO lifecycle policy
resource "aws_s3_bucket" "vp_test_logs" {
  bucket = "vp-test-logs-bucket-e2e-insecure"

  tags = merge(local.common_tags, {
    Name = "vp-test-logs-bucket"
  })
}

# Public bucket with permissive policy — triggers S3.2, S3.3
resource "aws_s3_bucket" "vp_test_public_bucket" {
  bucket = "vp-test-public-bucket-e2e-insecure"

  tags = merge(local.common_tags, {
    Name = "vp-test-public-bucket"
  })
}

# Allow public read — explicitly insecure
resource "aws_s3_bucket_policy" "vp_test_public_bucket_policy" {
  bucket = aws_s3_bucket.vp_test_public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.vp_test_public_bucket.arn}/*"
      }
    ]
  })
}
