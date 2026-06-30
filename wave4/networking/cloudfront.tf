# CloudFront resources with intentionally non-compliant configurations
# Wave 4 — ~$0/day (no traffic), $0.085/10K requests
#
# Triggered controls:
#   CloudFront.1  — Distributions should have a default root object configured
#   CloudFront.3  — Distributions should require encryption in transit
#   CloudFront.4  — Distributions should have origin failover configured
#   CloudFront.5  — Distributions should have logging enabled
#   CloudFront.6  — Distributions should have WAF enabled
#   CloudFront.7  — Distributions should use custom SSL/TLS certificates
#   CloudFront.8  — Distributions should use SNI to serve HTTPS requests
#   CloudFront.9  — Distributions should encrypt traffic to custom origins
#   CloudFront.10 — Distributions should not use deprecated SSL protocols
#   CloudFront.12 — Distributions should not point to non-existent S3 origins
#   CloudFront.13 — Distributions should use origin access control
#   CloudFront.14 — Distributions should be tagged

resource "aws_cloudfront_distribution" "vp_test" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "VectorPlane E2E test — intentionally non-compliant"

  # No default_root_object — triggers CloudFront.1

  origin {
    domain_name = "vp-e2e-test-nonexistent.s3.amazonaws.com"
    origin_id   = "S3Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1"]
    }
    # origin_protocol_policy = "http-only" — triggers CloudFront.9
    # TLSv1 — triggers CloudFront.10
    # No OAC — triggers CloudFront.13
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    # viewer_protocol_policy = "allow-all" — triggers CloudFront.3
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # cloudfront_default_certificate — triggers CloudFront.7
    # Default cert uses SNI but may trigger CloudFront.8 depending on config
  }

  # No logging_config — triggers CloudFront.5
  # No web_acl_id — triggers CloudFront.6
  # No tags — triggers CloudFront.14
}
