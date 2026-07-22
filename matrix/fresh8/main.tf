# matrix/fresh8 — violating API Gateway REST API + stage authored BARE so a single
# REST API stage trips MANY SecurityHub APIGateway controls at once:
#   APIGateway.1 — stage has NO access_log_settings block (execution/access logging off)
#   APIGateway.3 — xray_tracing_enabled = false (X-Ray tracing disabled)
#   APIGateway.4 — no aws_wafv2_web_acl_association for the stage (no WAF)
#   APIGateway.5 — method_settings has caching ENABLED but cache_data_encrypted absent (=false)
# Every violating attribute/block is deliberately OMITTED so the composer can inject it.

resource "aws_api_gateway_rest_api" "vp" {
  name        = "vp-fresh8-${random_id.s.hex}"
  description = "vp fresh8 violating REST API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "vp" {
  rest_api_id = aws_api_gateway_rest_api.vp.id
  parent_id   = aws_api_gateway_rest_api.vp.root_resource_id
  path_part   = "ping"
}

resource "aws_api_gateway_method" "vp" {
  rest_api_id   = aws_api_gateway_rest_api.vp.id
  resource_id   = aws_api_gateway_resource.vp.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vp" {
  rest_api_id = aws_api_gateway_rest_api.vp.id
  resource_id = aws_api_gateway_resource.vp.id
  http_method = aws_api_gateway_method.vp.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_deployment" "vp" {
  rest_api_id = aws_api_gateway_rest_api.vp.id
  depends_on  = [aws_api_gateway_integration.vp]
  lifecycle {
    create_before_destroy = true
  }
}

# Violating stage: no access_log_settings (APIGateway.1), X-Ray off (APIGateway.3),
# no WAF association (APIGateway.4).
resource "aws_api_gateway_stage" "vp" {
  rest_api_id          = aws_api_gateway_rest_api.vp.id
  deployment_id        = aws_api_gateway_deployment.vp.id
  stage_name           = "prod"
  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = "arn:aws:logs:us-east-1:746210888062:log-group:/vp/companion/856b2431"
    format          = "$context.requestId $context.status $context.error.message $context.error.messageString"
  }
}

# Method settings: caching ENABLED so APIGateway.5 evaluates, but cache_data_encrypted
# is OMITTED (defaults false) → cache not encrypted at rest.
resource "aws_api_gateway_method_settings" "vp" {
  rest_api_id = aws_api_gateway_rest_api.vp.id
  stage_name  = aws_api_gateway_stage.vp.stage_name
  method_path = "*/*"
  settings {
    caching_enabled      = true
    metrics_enabled      = true
    cache_data_encrypted = true
  }
}
