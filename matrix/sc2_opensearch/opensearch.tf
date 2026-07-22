# VIOLATING OpenSearch domain — public, unencrypted, no HTTPS enforcement,
# no logging, single node, no fine-grained access control.
# Targets Opensearch.1/2/3/4/5/6/7/8
resource "aws_opensearch_domain" "violating" {
  domain_name    = "sc2-os-${random_id.s.hex}"
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  # VIOLATING: HTTPS not enforced + outdated TLS policy (Opensearch.3 / Opensearch.8)
  domain_endpoint_options {
    enforce_https       = false
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # NOTE: intentionally OMITTED to fire controls:
  #  - encrypt_at_rest            -> Opensearch.1 (encryption at rest)
  #  - node_to_node_encryption    -> Opensearch.2 (node-to-node encryption)
  #  - log_publishing_options     -> Opensearch.4 / Opensearch.5 (error + audit logging)
  #  - advanced_security_options  -> Opensearch.7 (fine-grained access control)
  #  - single node (count=1)      -> Opensearch.6 (zone awareness / >=3 data nodes)

  vpc_options {
    security_group_ids = ["sg-055114eda16cd94b1"]
    subnet_ids         = ["subnet-0dd7628650cbd31c3"]
  }

  log_publishing_options {
    log_type                 = "AUDIT_LOGS"
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:746210888062:log-group:/vp/companion/856b2431"
    enabled                  = true
  }
}
