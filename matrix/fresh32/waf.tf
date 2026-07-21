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
}
