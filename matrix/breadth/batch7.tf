# =============================================================================
# Breadth violation matrix — batch 7 (EBS encryption controls)
# An unencrypted EBS volume triggers the EBS encryption controls:
#   - EC2.3  (AUTO)  encrypted = true
#   - EC2.45 (AUTO)  encrypted = true
#   - EC2.28 (INPUT) encrypted = true + kms_key_id = <customer KMS key ARN>
# Whichever control the account's standard emits, the campaign resolves it.
# =============================================================================

resource "aws_ebs_volume" "vp_ebs_cmk" {
  availability_zone = "us-east-1a"
  size              = 1
  encrypted         = false # EBS encryption violation (EC2.3/45/28)
  tags              = { Name = "vp-breadth-ebs-cmk-${local.sfx}" }
}

output "breadth_batch7" {
  value = { ebs_cmk = aws_ebs_volume.vp_ebs_cmk.id }
}
