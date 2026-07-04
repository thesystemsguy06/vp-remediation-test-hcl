# WAF resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   WAF.1  — Classic Global web ACL logging should be enabled
#   WAF.2  — Regional rule should have at least one condition
#   WAF.3  — Regional rule group should have at least one rule
#   WAF.4  — Classic Regional web ACL should have at least one rule
#   WAF.6  — Classic Global rule should have at least one condition
#   WAF.7  — Classic Global rule group should have at least one rule
#   WAF.8  — Classic Global web ACL should have at least one rule
#   WAF.10 — WAFv2 web ACL should have at least one rule or rule group
#   WAF.11 — WAF web ACL logging should be enabled
#   WAF.12 — WAF rules should have CloudWatch metrics enabled

variable "common_tags_security" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# --- WAFv2 (modern) ---

# WAFv2 web ACL — no rules, no logging — triggers WAF.10, WAF.11, WAF.12
resource "aws_wafv2_web_acl" "vp_test" {
  name  = "vp-test-insecure-wafv2"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "vp-test-wafv2"
    sampled_requests_enabled   = false
  }

  # No rules — triggers WAF.10
  # No logging — triggers WAF.11
  # cloudwatch_metrics_enabled = false — triggers WAF.12

  tags = var.common_tags_security
}

# IP set for blocking known malicious IPs
resource "aws_wafv2_ip_set" "vp_test_blocked_ips" {
  name               = "vp_test-blocked-ips"
  description        = "IP set for blocking known malicious IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    "10.0.0.0/8",
    "192.168.0.0/16"
  ]

  tags = {
    Name       = "vp_test-blocked-ips"
    Purpose    = "WAF IP blocking"
    Compliance = "SecurityHub-WAF.10"
  }
}


# WAFv2 rule group — empty
resource "aws_wafv2_rule_group" "vp_test" {
  name     = "vp-test-empty-rule-group"
  scope    = "REGIONAL"
  capacity = 10

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "vp-test-rule-group"
    sampled_requests_enabled   = false
  }

  tags = var.common_tags_security
}

# --- WAF Classic Global ---
# DISABLED: AWS deprecated WAF Classic v1 resource creation after May 2025.
# WAF Classic controls (WAF.1-8) cannot be tested via new resource creation.

# --- WAF Classic Regional ---
# DISABLED: Same deprecation applies to regional WAF Classic resources.
