# =============================================================================
# Breadth violation matrix — batch 2 (higher-yield, still no-VPC)
# =============================================================================

# ---- CloudFront: CloudFront.1/3/5/6/9 + TLS controls (highest yield) --------
resource "aws_cloudfront_distribution" "vp_cf" {
  http_version = "http2"
  enabled      = true
  # no default_root_object          -> CloudFront.1
  # no logging_config               -> CloudFront.5
  # no web_acl_id                   -> CloudFront.6
  comment = "vp-breadth-cf-${local.sfx}"

  origin {
    domain_name = "vp-breadth-origin-${local.sfx}.example.com"
    origin_id   = "vp-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # weak origin protocol
      origin_ssl_protocols   = ["TLSv1"]   # deprecated TLS -> CloudFront.16
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "vp-origin"
    viewer_protocol_policy = "redirect-to-https" # CloudFront.3 violation (no HTTPS enforce)

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # CloudFront.9-ish
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # default cert (no custom TLS)
    ssl_support_method             = "sni-only"
  }

  price_class = "PriceClass_100"

  logging_config {
    bucket          = "vp-companion-logs-856b2431.s3.amazonaws.com"
    prefix          = "cloudfront-logs/"
    include_cookies = false
  }
}

# ---- EBS volume: EC2.3 (encryption at rest) ---------------------------------
resource "aws_ebs_volume" "vp_ebs" {
  availability_zone = "us-east-1a"
  size              = 1
  encrypted         = false # EC2.3 violation
}

# ---- ECS cluster: ECS.12 (container insights) -------------------------------
resource "aws_ecs_cluster" "vp_ecs" {
  name = "vp-breadth-ecs-${local.sfx}"

  setting {
    name  = "containerInsights"
    value = "enabled" # ECS.12 violation
  }
}

# ---- Athena workgroup: Athena.4 (logging / config) --------------------------
resource "aws_athena_workgroup" "vp_athena" {
  name          = "vp-breadth-athena-${local.sfx}"
  force_destroy = true

  configuration {
    publish_cloudwatch_metrics_enabled = false # Athena.4-ish
  }
}

output "breadth_batch2" {
  value = {
    cloudfront = aws_cloudfront_distribution.vp_cf.id
    ebs        = aws_ebs_volume.vp_ebs.id
    ecs        = aws_ecs_cluster.vp_ecs.name
    athena     = aws_athena_workgroup.vp_athena.name
  }
}
