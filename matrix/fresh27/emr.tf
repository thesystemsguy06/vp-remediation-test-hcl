resource "aws_emr_security_configuration" "vp" {
  name          = "vp-f27-emr-${random_id.s.hex}"
  configuration = jsonencode({
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = false
    }
  })
}
