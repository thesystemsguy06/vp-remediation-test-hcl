resource "aws_route53_zone" "vp" {
  name          = "vp-${random_id.s.hex}-e2e.com"
  force_destroy = true

  # VIOLATING: Route53.2 — public hosted zone with no query logging
  # (no companion aws_route53_query_log resource)
}
