# Glue resources with intentionally non-compliant configurations
# Wave 1 — Free tier (first 1M objects/mo cataloged free), no VPC dependencies
#
# Triggered controls:
#   Glue.1 — Jobs should have security configuration
#   Glue.3 — Data catalog settings should use encryption at rest
#   Glue.4 — Spark Shuffle encryption should be enabled

resource "aws_iam_role" "vp_test_glue" {
  name = "vp-test-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_iam_role_policy_attachment" "vp_test_glue" {
  role       = aws_iam_role.vp_test_glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue job — no security configuration — triggers Glue.1, Glue.4
resource "aws_glue_job" "vp_test" {
  name     = "vp-test-insecure-glue-job"
  role_arn = aws_iam_role.vp_test_glue.arn

  command {
    script_location = "s3://placeholder-bucket/scripts/test.py"
    python_version  = "3"
  }

  glue_version = "4.0"

  # No security_configuration — triggers Glue.1, Glue.4

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Glue Data Catalog encryption — singleton resource per account/region
# Uncomment only if no existing catalog encryption settings exist
#
# resource "aws_glue_data_catalog_encryption_settings" "vp_test" {
#   data_catalog_encryption_settings {
#     connection_password_encryption {
#       return_connection_password_encrypted = false
#     }
#     encryption_at_rest {
#       catalog_encryption_mode = "DISABLED"
#     }
#   }
#   # encryption disabled — triggers Glue.3
# }
