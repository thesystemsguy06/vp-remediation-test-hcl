# Archive file block to produce a valid placeholder zip
data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "/tmp/lambda_placeholder.zip"
  source {
    content  = "def handler(event, context): return {'statusCode': 200}"
    filename = "index.py"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "vp_test_lambda_role" {
  name = "vp-test-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "vp-test-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "vp_test_lambda_basic" {
  role       = aws_iam_role.vp_test_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda with no VPC, no DLQ, no tracing — triggers Lambda.1, Lambda.3, Lambda.5
resource "aws_lambda_function" "vp_test_api_handler" {
  function_name = "vp-test-api-handler"
  role          = aws_iam_role.vp_test_lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_placeholder.output_path

  # No vpc_config — not in VPC (Lambda.1)
  # No dead_letter_config — no DLQ (Lambda.3)
  # No tracing_config — no X-Ray tracing (Lambda.5)

  tags = merge(local.common_tags, {
    Name = "vp-test-api-handler"
  })
}

# Lambda with no reserved concurrency and no tracing — triggers Lambda.5
resource "aws_lambda_function" "vp_test_processor" {
  function_name                  = "vp-test-processor"
  role                           = aws_iam_role.vp_test_lambda_role.arn
  handler                        = "index.handler"
  runtime                        = "python3.12"
  filename                       = data.archive_file.lambda_placeholder.output_path
  reserved_concurrent_executions = -1

  # No tracing_config — no X-Ray tracing (Lambda.5)

  tags = merge(local.common_tags, {
    Name = "vp-test-processor"
  })
}
