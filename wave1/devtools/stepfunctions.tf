# Step Functions resources with intentionally non-compliant configurations
# Wave 1 — Free tier (4,000 state transitions/mo), no VPC dependencies
#
# Triggered controls:
#   StepFunctions.1 — State machines should have logging turned on
#   StepFunctions.2 — Activities should be tagged

resource "aws_iam_role" "vp_test_sfn" {
  name = "vp-test-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# State machine — no logging, no tracing
resource "aws_sfn_state_machine" "vp_test" {
  name     = "vp-test-insecure-sfn"
  role_arn = aws_iam_role.vp_test_sfn.arn

  definition = jsonencode({
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type = "Pass"
        End  = true
      }
    }
  })

  # No logging_configuration — triggers StepFunctions.1
  # No tracing_configuration — no X-Ray

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Activity — no tags — triggers StepFunctions.2
resource "aws_sfn_activity" "vp_test" {
  name = "vp-test-insecure-activity"
  # No tags — triggers StepFunctions.2
}
