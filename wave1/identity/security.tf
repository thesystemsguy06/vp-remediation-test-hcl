# Security resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   ACM.1            — Certificates should be renewed within 90 days
#   ACM.2            — RSA certificates should use >= 2048 bit key
#   SecretsManager.1 — Secrets should have automatic rotation enabled
#   SecretsManager.3 — Remove unused secrets
#   SecretsManager.4 — Secrets should be rotated within specified days
#   Config.1         — AWS Config should be enabled

# ACM certificate — never validated, will trigger ACM.1
resource "aws_acm_certificate" "vp_test" {
  domain_name       = "vp-test-insecure.example.com"
  validation_method = "DNS"

  tags = var.common_tags_identity

  lifecycle {
    create_before_destroy = true
  }
}

# Secrets Manager secret — no rotation — triggers SecretsManager.1, 3, 4
resource "aws_secretsmanager_secret" "vp_test" {
  name        = "vp-test/insecure-secret"
  description = "VectorPlane E2E test — intentionally no rotation"

  # No kms_key_id — uses default encryption
  # No rotation configuration — triggers SecretsManager.1, 4

  tags = var.common_tags_identity
}

resource "aws_secretsmanager_secret_version" "vp_test" {
  secret_id     = aws_secretsmanager_secret.vp_test.id
  secret_string = jsonencode({
    username = "test-user"
    password = "test-password-not-real"
  })
}

# AWS Config recorder — incomplete configuration — triggers Config.1
# NOTE: Config recorder is a regional singleton. This may conflict with
# existing Config setup in the test account.
# Uncomment only if no Config recorder exists in the region.

# resource "aws_config_configuration_recorder" "vp_test" {
#   name     = "vp-test-config-recorder"
#   role_arn = aws_iam_role.vp_test_config.arn
#
#   recording_group {
#     all_supported                 = false
#     include_global_resource_types = false
#   }
# }
#
# resource "aws_iam_role" "vp_test_config" {
#   name = "vp-test-config-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "config.amazonaws.com" }
#     }]
#   })
#   tags = var.common_tags_identity
# }
