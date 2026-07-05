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
