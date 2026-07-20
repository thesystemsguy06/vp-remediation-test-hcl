resource "aws_emr_security_configuration" "vp" {
  name          = "vp-f28-emr-${random_id.s.hex}"
  configuration = jsonencode({ EncryptionConfiguration = { EnableInTransitEncryption = false, EnableAtRestEncryption = false } })
}
