# KMS key with rotation disabled and short deletion window
# — triggers KMS.1, KMS.3
resource "aws_kms_key" "vp_test" {
  description             = "VectorPlane E2E test key — intentionally insecure"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "vp-test-key"
  })
}

resource "aws_kms_alias" "vp_test_key_alias" {
  name          = "alias/vp-test-key"
  target_key_id = aws_kms_key.vp_test.key_id
}
