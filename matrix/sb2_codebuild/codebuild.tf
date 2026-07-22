# matrix/sb2_codebuild — CodeBuild project authored BARE so it trips several SecurityHub
# CodeBuild controls at once:
#   CodeBuild.2 — a PLAINTEXT environment_variable holds a credential-looking value
#                 (secret should live in Secrets Manager / Parameter Store, not clear text)
#   CodeBuild.3 — S3 build logs are not encrypted (no encrypted logging configured)
#   CodeBuild.4 — no logging configuration active (both CloudWatch + S3 logs DISABLED)
# The insecure dimensions (clear-text secret, disabled/unencrypted logging) are set
# explicitly so the composer can rewrite them to a compliant configuration.
resource "aws_codebuild_project" "vp" {
  name         = "vp-sb2-cb-${random_id.s.hex}"
  service_role = "arn:aws:iam::746210888062:role/vp-companion-856b2431"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    # Violating: a credential-looking secret exposed as a PLAINTEXT env var.
    environment_variable {
      name  = "AWS_SECRET_ACCESS_KEY"
      value = "wJalrXUtnFEMIbKEXAMPLEKEYbPxRfiCYzKEY42"
      type  = "PLAINTEXT"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = "version: 0.2\nphases:\n  build:\n    commands:\n      - echo hello"
  }

  # Violating: all logging disabled (CodeBuild.4) and no encrypted S3 log target (CodeBuild.3).
  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
    s3_logs {
      status = "DISABLED"
    }
  }
}
