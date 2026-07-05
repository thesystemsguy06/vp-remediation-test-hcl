# API Gateway resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   APIGateway.1  — REST/WebSocket API execution logging should be enabled
#   APIGateway.2  — REST API stages should use SSL certificates
#   APIGateway.3  — REST API stages should have X-Ray tracing enabled
#   APIGateway.5  — REST API cache data should be encrypted at rest
#   APIGateway.8  — Routes should specify an authorization type
#   APIGateway.9  — Access logging should be configured for V2 Stages

# --- REST API (v1) ---

resource "aws_api_gateway_rest_api" "vp_test" {
  name        = "vp-test-insecure-rest-api"
  description = "VectorPlane E2E test — intentionally non-compliant"

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_api_gateway_deployment" "vp_test" {
  rest_api_id = aws_api_gateway_rest_api.vp_test.id

  lifecycle {
    create_before_destroy = true
  }
}

# Stage with no logging, no X-Ray, no SSL cert — triggers APIGateway.1, 2, 3
resource "aws_api_gateway_stage" "vp_test" {
  deployment_id = aws_api_gateway_deployment.vp_test.id
  rest_api_id   = aws_api_gateway_rest_api.vp_test.id
  stage_name    = "test"

  xray_tracing_enabled = false

  # No access_log_settings — triggers APIGateway.1
  # No client_certificate_id — triggers APIGateway.2
  # xray_tracing_enabled = false — triggers APIGateway.3

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Method settings — logging OFF, cache not encrypted — triggers APIGateway.5
resource "aws_api_gateway_method_settings" "vp_test" {
  rest_api_id = aws_api_gateway_rest_api.vp_test.id
  stage_name  = aws_api_gateway_stage.vp_test.stage_name
  method_path = "*/*"

  settings {
    logging_level        = "OFF"
    data_trace_enabled   = false
    metrics_enabled      = false
    cache_data_encrypted = false
  }
}

# --- HTTP API (v2) ---

resource "aws_apigatewayv2_api" "vp_test" {
  name          = "vp-test-insecure-http-api"
  protocol_type = "HTTP"

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_apigatewayv2_integration" "vp_test" {
  api_id             = aws_apigatewayv2_api.vp_test.id
  integration_type   = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri    = "https://httpbin.org/get"
}

# Route with no authorization — triggers APIGateway.8
resource "aws_apigatewayv2_route" "vp_test" {
  api_id    = aws_apigatewayv2_api.vp_test.id
  route_key = "GET /test"
  target    = "integrations/${aws_apigatewayv2_integration.vp_test.id}"

  authorization_type = "NONE"
}

# Stage with no access logging — triggers APIGateway.9
resource "aws_apigatewayv2_stage" "vp_test" {
  api_id      = aws_apigatewayv2_api.vp_test.id
  name        = "test"
  auto_deploy = true

  # No access_log_settings — triggers APIGateway.9

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# CloudWatch Log Group for API Gateway V2 Stage Access Logs
resource "aws_cloudwatch_log_group" "vp_test_access_logs" {
  name              = "/aws/apigateway/vp_test"
  retention_in_days = 14

  tags = {
    Name       = "vp_test-apigateway-access-logs"
    Purpose    = "API Gateway V2 Stage Access Logging"
    Compliance = "SecurityHub-APIGateway.9"
  }
}

# IAM Role for API Gateway CloudWatch Logs (Account-level)
resource "aws_iam_role" "vp_test_apigateway_logs_role" {
  name = "vp_test-apigateway-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name       = "vp_test-apigateway-logs-role"
    Purpose    = "API Gateway CloudWatch Logs Access"
    Compliance = "SecurityHub-APIGateway.9"
  }
}

# IAM Policy for API Gateway CloudWatch Logs
resource "aws_iam_role_policy" "vp_test_apigateway_logs_policy" {
  name = "vp_test-apigateway-logs-policy"
  role = aws_iam_role.vp_test_apigateway_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# API Gateway Account Configuration for CloudWatch Logs
resource "aws_api_gateway_account" "vp_test_account" {
  cloudwatch_role_arn = aws_iam_role.vp_test_apigateway_logs_role.arn
}

