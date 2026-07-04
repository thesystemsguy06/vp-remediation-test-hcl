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

resource "aws_cloudwatch_log_group" "vp_test_log_group" {
  name              = "/aws/stepfunctions/vp_test"
  retention_in_days = 14

  tags = {
    Name       = "vp_test-stepfunctions-logs"
    Purpose    = "Step Functions state machine logging"
    Compliance = "SecurityHub-StepFunctions.1"
  }
}

resource "aws_iam_role" "vp_test_logging_role" {
  name = "vp_test-stepfunctions-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name       = "vp_test-stepfunctions-logging-role"
    Purpose    = "Step Functions logging permissions"
    Compliance = "SecurityHub-StepFunctions.1"
  }
}

resource "aws_iam_role_policy" "vp_test_logging_policy" {
  name = "vp_test-stepfunctions-logging-policy"
  role = aws_iam_role.vp_test_logging_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = aws_cloudwatch_log_group.vp_test_log_group.arn
      }
    ]
  })
}


# Activity — no tags — triggers StepFunctions.2
resource "aws_sfn_activity" "vp_test" {
  name = "vp-test-insecure-activity"
  # No tags — triggers StepFunctions.2
}
