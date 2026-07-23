resource "aws_wafregional_web_acl" "test" {
  name        = "vpb4wafregionalacl"
  metric_name = "vpb4wafregionalacl"
  default_action {
    type = "ALLOW"
  }
}
