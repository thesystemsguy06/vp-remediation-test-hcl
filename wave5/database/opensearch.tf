# OpenSearch resources with intentionally non-compliant configurations
# Wave 5 — ~$3-5/day (t3.small.search)
#
# Triggered controls:
#   OpenSearch.1  — Domains should have encryption at rest enabled
#   OpenSearch.2  — Domains should not be publicly accessible
#   OpenSearch.3  — Domains should encrypt data sent between nodes
#   OpenSearch.4  — Domain error logging to CloudWatch Logs should be enabled
#   OpenSearch.5  — Domains should have audit logging enabled
#   OpenSearch.6  — Domains should have at least three data nodes
#   OpenSearch.7  — Domains should have fine-grained access control enabled
#   OpenSearch.8  — Connections to domains should be encrypted using TLS 1.2
#   OpenSearch.10 — Domains should have the latest software update installed
#   OpenSearch.11 — Domains should have at least three dedicated master nodes

# OpenSearch domain — no encryption, public, single node
resource "aws_opensearch_domain" "vp_test" {
  domain_name    = "vp-test-insecure"
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 1

    # instance_count = 1 — triggers OpenSearch.6 (should be >= 3)
    # No dedicated_master_enabled — triggers OpenSearch.11
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  encrypt_at_rest {
    enabled = false
    # enabled = false — triggers OpenSearch.1
  }

  node_to_node_encryption {
    enabled = false
    # enabled = false — triggers OpenSearch.3
  }

  domain_endpoint_options {
    enforce_https       = false
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
    # enforce_https = false — triggers OpenSearch.8
    # TLS 1.0 — triggers OpenSearch.8
  }

  # No advanced_security_options — triggers OpenSearch.7
  # No log_publishing_options — triggers OpenSearch.4, OpenSearch.5

  tags = var.common_tags
}
