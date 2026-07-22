# matrix/sd1_apigwv2 — HTTP API + stage authored BARE so it trips API Gateway logging controls:
#   APIGateway.x — API Gateway V2 stages should have access logging enabled
# The stage has auto_deploy but NO access_log_settings block (access logging disabled).
# The composer's fix adds an access_log_settings block (destination_arn + format).
resource "aws_apigatewayv2_api" "vp" {
  name          = "vp-sd1-apigwv2-${random_id.s.hex}"
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_stage" "vp" {
  api_id      = aws_apigatewayv2_api.vp.id
  name        = "vp-sd1-stage-${random_id.s.hex}"
  auto_deploy = true
}
