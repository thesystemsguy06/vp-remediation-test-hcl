# VIOLATING: SES configuration set that does NOT require TLS on delivery -> SES.2
# and has reputation metrics disabled -> SES.3
# tls_policy "Optional" (vs "Require") means mail can be sent over cleartext.
resource "aws_ses_configuration_set" "sa1_insecure" {
  name                       = "sa1-cfgset-${random_id.s.hex}"
  reputation_metrics_enabled = false

  delivery_options {
    tls_policy = "Optional"
  }
}
