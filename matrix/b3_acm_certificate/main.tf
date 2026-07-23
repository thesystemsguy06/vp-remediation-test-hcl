resource "aws_acm_certificate" "vp_b3" {
  domain_name       = "vp-b3-test.example.com"
  validation_method = "DNS"
}
