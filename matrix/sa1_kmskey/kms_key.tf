# VIOLATING: KMS key with rotation DISABLED -> KMS.5
# (KMS.3 = key should not be scheduled for deletion; the key is scheduled for
#  deletion out-of-band after apply so it enters PendingDeletion state.)
resource "aws_kms_key" "sa1_norotate" {
  is_enabled              = true
  description             = "VP e2e violating fixture ${random_id.s.hex}: rotation disabled"
  enable_key_rotation     = false
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "sa1_norotate" {
  name          = "alias/sa1-norotate-${random_id.s.hex}"
  target_key_id = aws_kms_key.sa1_norotate.key_id
}
