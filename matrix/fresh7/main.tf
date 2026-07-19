# matrix/fresh7 — violating CLOUDFRONT DISTRIBUTION with a self-contained private
# S3 origin. Authored BARE/insecure so ONE distribution trips MANY SecurityHub
# CloudFront controls at once. Every hardening attribute is deliberately OMITTED
# (or set to its insecure value) so the composer can inject it:
#   CloudFront.1  — no default_root_object
#   CloudFront.3  — viewer_protocol_policy = "allow-all" (not redirect/https-only)
#   CloudFront.5  — no logging_config (access logging disabled)
#   CloudFront.6  — no web_acl_id (no WAF)
#   CloudFront.9  — no http_version = http2 (defaults to http1.1)
#   CloudFront.13 — S3 origin uses empty OAI, no origin access control (OAC)
#   (weak TLS: default CloudFront certificate forces minimum_protocol_version=TLSv1)
# The distribution is deployable (has one origin + default_cache_behavior) but
# intentionally non-compliant across the board.

resource "aws_s3_bucket" "origin" {
  bucket        = "vp-fresh7-origin-${random_id.s.hex}"
  force_destroy = true
}

resource "aws_cloudfront_distribution" "vp_cf" {
  default_root_object = "index.html"
  enabled             = true
  comment             = "vp-fresh7 intentionally-insecure distribution"

  # Private S3 origin with NO origin access control and empty OAI => public/legacy.
  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # Second origin so CloudFront.4 origin-failover can reference a real failover member.
  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "s3-failover"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # Insecure default behavior: HTTP allowed (viewer_protocol_policy = allow-all).
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Default CloudFront cert => weak minimum TLS (TLSv1); no ACM/custom cert.
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }


  logging_config {
    bucket          = "vp-cf-logs-a97ab2f7.s3.amazonaws.com"
    prefix          = "cloudfront-logs/"
    include_cookies = false
  }

  origin_group {
    origin_id = "vp-origin-group"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "s3-origin"
    }

    member {
      origin_id = "s3-failover"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "main_oac" {
  name                              = "cloudfront-oac"
  description                       = "OAC for CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

