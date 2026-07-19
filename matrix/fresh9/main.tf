# matrix/fresh9 — violating Cognito user pool authored to trip MANY SecurityHub
# Cognito controls at once:
#   Cognito.1 — no user_pool_add_ons block (advanced security not ENFORCED)
#   Cognito.3 — deliberately WEAK password_policy (len 6, no char-class requirements)
#   Cognito.4 — no advanced_security_additional_flows (custom auth not ENFORCED)
#   Cognito.5 — no software_token_mfa_configuration (MFA off)
#   Cognito.6 — deletion_protection omitted (defaults INACTIVE)
# Every compliant attribute/block is deliberately OMITTED (or weakened) so the
# composer can inject it. Cognito.2 already applied in an earlier wave.

resource "aws_cognito_user_pool" "vp" {
  name = "vp-fresh9-${random_id.s.hex}"

  # Cognito.3: explicit weak policy so the control evaluates and FAILS
  # (an omitted policy would inherit compliant-ish defaults and not fire).
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
  }
}
