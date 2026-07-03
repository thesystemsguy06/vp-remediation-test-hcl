# Route 53 resources with intentionally non-compliant configurations
# Wave 1 — Hosted zone: $0.50/mo, health check: $0.50/mo
#
# Triggered controls:
#   Route53.1 — Health check not tagged
#   Route53.2 — Public hosted zone has no query logging

# Public hosted zone — no query logging — triggers Route53.2
resource "aws_route53_zone" "vp_test" {
  name = "vp-test-e2e.vectorplane.dev"

  # No aws_route53_query_log — triggers Route53.2

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Health check — no tags — triggers Route53.1
resource "aws_route53_health_check" "vp_test" {
  type              = "HTTPS"
  fqdn              = "example.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  # No tags — triggers Route53.1
}
