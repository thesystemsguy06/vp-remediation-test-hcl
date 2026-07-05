# Athena resources with intentionally non-compliant configurations
# Wave 1 — Free tier (pay per query, $0 if no queries run), no VPC dependencies
#
# Triggered controls:
#   Athena.2 — Data catalogs should be tagged
#   Athena.3 — Workgroups should have query results encryption enabled
#   Athena.4 — Workgroups should enforce workgroup configuration

# Workgroup — no encryption, no enforcement — triggers Athena.3, Athena.4
resource "aws_athena_workgroup" "vp_test" {
  name = "vp-test-insecure-workgroup"

  configuration {
    enforce_workgroup_configuration = false

    result_configuration {
      output_location = "s3://placeholder-bucket/athena-results/"
      # No encryption_configuration — triggers Athena.3
    }
  }

  # enforce_workgroup_configuration = false — triggers Athena.4

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Data catalog — no tags — triggers Athena.2
resource "aws_athena_data_catalog" "vp_test" {
  name        = "vp-test-insecure-catalog"
  description = "VectorPlane E2E test — intentionally no tags"
  type        = "HIVE"

  parameters = {
    "metadata-function" = "arn:aws:lambda:us-east-1:123456789012:function:placeholder"
  }

  # No tags — triggers Athena.2
}
