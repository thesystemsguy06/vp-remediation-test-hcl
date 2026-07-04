# Cognito resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   Cognito.1 — User pools should have full-function advanced security enabled

resource "aws_cognito_user_pool" "vp_test" {
  name = "vp-test-insecure-pool"

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  mfa_configuration = ON

  # No user_pool_add_ons with advanced_security_mode — triggers Cognito.1

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_cognito_identity_pool" "vp_test" {
  identity_pool_name               = "vp_test_insecure_identity"
  allow_unauthenticated_identities = true

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}
