# KMS resources with intentionally non-compliant configurations
# Wave 1 — Free tier (KMS keys cost $1/mo each)
#
# Triggered controls:
#   KMS.1 — Key policies should restrict public access
#   KMS.3 — Keys should not be deleted unintentionally
#   KMS.4 — Key rotation should be enabled

data "aws_caller_identity" "current_kms" {}

# KMS key — no rotation, short deletion window, permissive policy
resource "aws_kms_key" "vp_test" {
  description             = "VectorPlane E2E test — intentionally non-compliant"
  deletion_window_in_days = 7
  enable_key_rotation     = false

  # Overly permissive key policy — triggers KMS.1
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccount"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current_kms.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowPublicAccess"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  # enable_key_rotation = false — triggers KMS.4
  # deletion_window_in_days = 7 — triggers KMS.3

  tags = var.common_tags_security
}

resource "aws_kms_alias" "vp_test" {
  name          = "alias/vp-test-insecure-key"
  target_key_id = aws_kms_key.vp_test.key_id
}
