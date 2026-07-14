# Cognito resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   Cognito.1 — User pools should have full-function advanced security enabled

resource "aws_cognito_user_pool" "vp_test" {
  name = "vp-test-insecure-pool"

  # Threat protection (advanced_security_mode) requires the PLUS tier
  user_pool_tier = "PLUS"

  # Remediated: Cognito.3 (strong password policy) — ensure-value strengthened
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  deletion_protection = "ACTIVE"

  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  # No user_pool_add_ons with advanced_security_mode — triggers Cognito.1

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"

    # Cognito.4 — threat protection for CUSTOM authentication
    advanced_security_additional_flows {
      custom_auth_mode = "ENFORCED"
    }
  }
}

resource "aws_cognito_identity_pool" "vp_test" {
  identity_pool_name               = "vp_test_insecure_identity"
  allow_unauthenticated_identities = false

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}
