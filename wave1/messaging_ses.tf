# SES resources with intentionally non-compliant configurations
# Wave 1 — Free tier (62,000 emails/mo from EC2), no VPC dependencies
#
# Triggered controls:
#   SES.1 — Contact lists should be tagged
#   SES.2 — Configuration sets should have TLS enforcement

# Configuration set — no TLS policy — triggers SES.2
resource "aws_ses_configuration_set" "vp_test" {
  name = "vp-test-insecure-ses"
  # No delivery_options with tls_policy — triggers SES.2
}

# SESv2 contact list — no tags — triggers SES.1
resource "aws_sesv2_contact_list" "vp_test" {
  contact_list_name = "vp-test-contact-list"
  # No tags — triggers SES.1
}
