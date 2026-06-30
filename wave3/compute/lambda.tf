# Lambda resources with intentionally non-compliant configurations
# Wave 3 — Pay-per-invoke (free tier: 1M requests/mo)
#
# Triggered controls:
#   Lambda.1 — Lambda function policies should prohibit public access
#   Lambda.2 — Lambda functions should use supported runtimes
#   Lambda.3 — Lambda functions should be in a VPC
#   Lambda.5 — Lambda functions should not be public (resource policy)
#   Lambda.6 — Lambda functions should be tagged

resource "aws_iam_role" "vp_test_lambda" {
  name = "vp-test-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_lambda" {
  role       = aws_iam_role.vp_test_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda source code
data "archive_file" "vp_test_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = "def handler(event, context): return {'statusCode': 200, 'body': 'test'}"
    filename = "index.py"
  }
}

# Lambda function — deprecated runtime, not in VPC, no tags
resource "aws_lambda_function" "vp_test" {
  function_name    = "vp-test-insecure-function"
  role             = aws_iam_role.vp_test_lambda.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.vp_test_lambda.output_path
  source_code_hash = data.archive_file.vp_test_lambda.output_base64sha256

  # python3.9 may be approaching EOL — triggers Lambda.2
  # No VPC config — triggers Lambda.3
  # No tags beyond default — triggers Lambda.6

  # Intentionally NO tags to trigger Lambda.6
}

# Public access permission — triggers Lambda.1, Lambda.5
resource "aws_lambda_permission" "vp_test_public" {
  statement_id  = "AllowPublicInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vp_test.function_name
  principal     = "*"

  # principal = "*" — triggers Lambda.1, Lambda.5
}
