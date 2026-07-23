resource "aws_appsync_graphql_api" "test" {
  name                = "vp-b4-appsync-api"
  authentication_type = "API_KEY"
}

resource "aws_appsync_api_cache" "test" {
  api_id                     = aws_appsync_graphql_api.test.id
  type                       = "SMALL"
  api_caching_behavior       = "FULL_REQUEST_CACHING"
  ttl                        = 300
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
}
