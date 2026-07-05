# IAM resources with intentionally weak/non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   IAM.1   — Policies should not allow full "*" admin privileges
#   IAM.2   — Users should not have IAM policies attached directly
#   IAM.3   — Access keys should be rotated every 90 days
#   IAM.5   — MFA should be enabled for console users
#   IAM.7   — Password policy should have strong config
#   IAM.8   — Unused credentials should be disabled after 90 days
#   IAM.15  — Password policy requires minimum length 14
#   IAM.16  — Password policy prevents password reuse
#   IAM.17  — Password policy expires passwords within 90 days
#   IAM.21  — Customer managed policies should not allow wildcard actions

variable "common_tags_identity" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Weak password policy — triggers IAM.7, IAM.15, IAM.16, IAM.17
resource "aws_iam_account_password_policy" "vp_test" {
  minimum_password_length        = 6
  require_lowercase_characters   = false
  require_numbers                = false
  require_uppercase_characters   = false
  require_symbols                = false
  allow_users_to_change_password = false
  max_password_age               = 0
  password_reuse_prevention      = 0
}

# IAM user with direct policy attachment — triggers IAM.2, IAM.5
resource "aws_iam_user" "vp_test" {
  name = "vp-test-insecure-user"
  tags = var.common_tags_identity
}

# Console access without MFA — triggers IAM.5
resource "aws_iam_user_login_profile" "vp_test" {
  user                    = aws_iam_user.vp_test.name
  password_reset_required = false
}

# Access key — triggers IAM.3, IAM.8
resource "aws_iam_access_key" "vp_test" {
  user = aws_iam_user.vp_test.name
}

# Inline policy on user with wildcard — triggers IAM.2, IAM.21
resource "aws_iam_user_policy" "vp_test" {
  name = "vp-test-overprivileged-inline"
  user = aws_iam_user.vp_test.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

# Managed policy with full admin — triggers IAM.1
resource "aws_iam_policy" "vp_test_overprivileged" {
  name        = "vp-test-full-admin-policy"
  description = "Intentionally overprivileged for E2E testing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })

  tags = var.common_tags_identity
}

# Attach managed policy directly to user — triggers IAM.2
resource "aws_iam_user_policy_attachment" "vp_test" {
  user       = aws_iam_user.vp_test.name
  policy_arn = aws_iam_policy.vp_test_overprivileged.arn
}

# Role with overly broad KMS permissions
resource "aws_iam_role" "vp_test_broad_kms" {
  name = "vp-test-broad-kms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.common_tags_identity
}

resource "aws_iam_role_policy" "vp_test_broad_kms" {
  name = "vp-test-broad-kms-inline"
  role = aws_iam_role.vp_test_broad_kms.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "kms:*"
      Resource = "*"
    }]
  })
}
