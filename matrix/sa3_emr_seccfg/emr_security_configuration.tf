# matrix/sa3_emr_seccfg — EMR security configuration with BOTH encryption
# dimensions disabled. Targets:
#   EMR.3 — EMR security configurations should enable encryption at rest
#   EMR.4 — EMR security configurations should enable encryption in transit
# EnableInTransitEncryption + EnableAtRestEncryption are both false (the insecure
# dimensions); the composer's fix is to flip them true and add the key providers.
resource "aws_emr_security_configuration" "vp" {
  name = "vp-sa3-emrsc-${random_id.s.hex}"

  configuration = jsonencode({
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = false
    }
  })
}
