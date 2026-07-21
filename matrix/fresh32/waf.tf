resource "aws_wafv2_web_acl" "vp" {
  name  = "vp-f32-waf-${random_id.s.hex}"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "vpf32"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendlyRuleName"
      sampled_requests_enabled   = false
    }
  }
}
