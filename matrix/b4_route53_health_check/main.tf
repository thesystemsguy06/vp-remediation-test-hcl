resource "aws_route53_health_check" "test" {
  fqdn              = "vp-b4-example.com"
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}
