# WAF.8: WAF Classic global web ACL should have at least one rule -> deploy with NO rules
resource "aws_waf_web_acl" "insecure" {
  name        = "vpinsecurewafb2"
  metric_name = "vpinsecurewafb2"
  default_action {
    type = "ALLOW"
  }
  # intentionally no `rules {}` block -> empty ACL violates WAF.8
}
