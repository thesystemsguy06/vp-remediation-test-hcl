# Miscellaneous service resources with intentionally non-compliant configurations
# Wave 1 — Free tier or minimal cost, no VPC dependencies
#
# Triggered controls:
#   Amplify.1    — Auto branch creation not configured
#   Amplify.2    — Auto build disabled
#   Detective.1  — Graph should be tagged

# --- Amplify ---

# Amplify app — no auto branch creation — triggers Amplify.1
resource "aws_amplify_app" "vp_test" {
  name = "vp-e2e-test-amplify"
  # No auto_branch_creation_config — triggers Amplify.1

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Amplify branch — auto build disabled — triggers Amplify.2
resource "aws_amplify_branch" "vp_test" {
  app_id            = aws_amplify_app.vp_test.id
  branch_name       = "main"
  enable_auto_build = false

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# --- Detective ---

# Detective graph — triggers Detective.1
resource "aws_detective_graph" "vp_test" {
  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# --- Commented-out resources that need special handling ---

# Macie — costs money if it scans S3 data
# resource "aws_macie2_account" "vp_test" {
#   finding_publishing_frequency = "FIFTEEN_MINUTES"
#   status                       = "ENABLED"
#   # No export config — triggers Macie.1
#   # No auto-discovery — triggers Macie.2
# }

# Inspector — account-level singleton, may conflict with existing config
# resource "aws_inspector2_enabler" "vp_test" {
#   account_ids    = [data.aws_caller_identity.current.account_id]
#   resource_types = ["EC2"]
#   # Missing ECR (Inspector.1), LAMBDA (Inspector.3), LAMBDA_CODE (Inspector.4)
# }

# Account alternate contact — singleton, overwrites existing
# resource "aws_account_alternate_contact" "vp_test" {
#   alternate_contact_type = "SECURITY"
#   name                   = "VectorPlane E2E Test"
#   email_address          = "security-test@example.com"
#   phone_number           = "+1-555-000-0000"
#   title                  = "E2E Test Security Contact"
#   # Triggers Account.1
# }
