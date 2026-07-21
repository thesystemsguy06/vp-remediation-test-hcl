# VIOLATING: customer-managed IAM policy with full admin ("*"/"*") -> IAM.11
# plus an explicit kms:Decrypt / kms:ReEncryptFrom on all keys -> KMS.1
resource "aws_iam_policy" "sa1_admin" {
  name        = "sa1-admin-${random_id.s.hex}"
  description = "VP e2e violating fixture: overly-permissive admin + KMS decrypt on all keys"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "FullAdmin"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid    = "DecryptAllKeys"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ]
        Resource = "*"
      }
    ]
  })
}
