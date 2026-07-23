resource "aws_ec2_client_vpn_endpoint" "test" {
  description            = "vp-b4-client-vpn"
  server_certificate_arn = "arn:aws:acm:us-east-1:746210888062:certificate/99f6bba1-122d-4a33-95ba-7e4b35bad3de"
  client_cidr_block      = "10.100.0.0/22"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:us-east-1:746210888062:certificate/99f6bba1-122d-4a33-95ba-7e4b35bad3de"
  }

  connection_log_options {
    enabled = false
  }
}
