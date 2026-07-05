# AppSync resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   AppSync.2 — Should have request-level and field-level logging
#   AppSync.4 — Should be associated with a WAF web ACL
#   AppSync.5 — Should not be authenticated with API keys

resource "aws_appsync_graphql_api" "vp_test" {
  name                = "vp-test-insecure-api"
  authentication_type = AWS_IAM

  schema = <<-SCHEMA
    type Query {
      hello: String
    }
  SCHEMA

  # API_KEY auth — triggers AppSync.5
  # No log_config block — triggers AppSync.2
  # No WAF association — triggers AppSync.4

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# CloudWatch Log Group for AppSync logging
resource "aws_cloudwatch_log_group" "vp_test_log_group" {
  name              = "/aws/appsync/apis/${aws_appsync_graphql_api.vp_test.id}"
  retention_in_days = 7

  tags = {
    Name       = "vp_test-appsync-logs"
    Purpose    = "AppSync field-level logging"
    Compliance = "SecurityHub-AppSync.2"
  }
}

# IAM Role for AppSync CloudWatch logging
resource "aws_iam_role" "vp_test_logs_role" {
  name = "vp_test-appsync-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name       = "vp_test-appsync-logs-role"
    Purpose    = "AppSync CloudWatch logging permissions"
    Compliance = "SecurityHub-AppSync.2"
  }
}

# IAM Policy for CloudWatch Logs permissions
resource "aws_iam_role_policy" "vp_test_logs_policy" {
  name = "vp_test-appsync-logs-policy"
  role = aws_iam_role.vp_test_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.vp_test_log_group.arn,
          "${aws_cloudwatch_log_group.vp_test_log_group.arn}:*"
        ]
      }
    ]
  })
}

