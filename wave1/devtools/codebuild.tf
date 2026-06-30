# CodeBuild resources with intentionally non-compliant configurations
# Wave 1 — Free tier (100 build minutes/mo), no VPC dependencies
#
# Triggered controls:
#   CodeBuild.3 — S3 logs should be encrypted
#   CodeBuild.4 — Environments should use logging configuration
#   CodeBuild.5 — Environments should not have privileged mode enabled
#   CodeBuild.7 — Environment variables should not contain clear text credentials

resource "aws_iam_role" "vp_test_codebuild" {
  name = "vp-test-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# CodeBuild project — privileged mode, no logging, plaintext credentials
resource "aws_codebuild_project" "vp_test" {
  name         = "vp-test-insecure-build"
  service_role = aws_iam_role.vp_test_codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Plaintext credential — triggers CodeBuild.7
    environment_variable {
      name  = "AWS_ACCESS_KEY_ID"
      value = "AKIAIOSFODNN7EXAMPLE"
      type  = "PLAINTEXT"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = "version: 0.2\nphases:\n  build:\n    commands:\n      - echo test"
  }

  # No logs_config — triggers CodeBuild.3, CodeBuild.4
  # privileged_mode = true — triggers CodeBuild.5

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Report group — no tags
resource "aws_codebuild_report_group" "vp_test" {
  name = "vp-test-report-group"
  type = "TEST"

  export_config {
    type = "NO_EXPORT"
  }

  # No tags
}
