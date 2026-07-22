# matrix/sb2_appsync — AppSync GraphQL API authored BARE so it trips AppSync controls:
#   AppSync.5 — API is authenticated with an API key (should use IAM / Cognito / OIDC)
#   AppSync.2 — no log_config block (request-level / field-level logging disabled)
# authentication_type = "API_KEY" and the omitted log_config are the insecure dimensions;
# the composer's fix adds a log_config and/or a stronger authentication provider.
resource "aws_appsync_graphql_api" "vp" {
  name                = "vp-sb2-appsync-${random_id.s.hex}"
  authentication_type = "AWS_IAM"
}
