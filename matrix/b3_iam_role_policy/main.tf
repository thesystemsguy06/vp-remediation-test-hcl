resource "aws_iam_role_policy" "vp_b3" {
  name = "vp-b3-kms-decrypt-all"
  role = "vp-companion-856b2431"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["kms:Decrypt", "kms:ReEncryptFrom"], Resource = "*" }]
  })
}
