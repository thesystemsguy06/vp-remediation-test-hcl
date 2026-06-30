# ElastiCache resources with intentionally non-compliant configurations
# Wave 4 — ~$3-5/day (cache.t3.micro)
#
# Triggered controls:
#   ElastiCache.1 — Clusters should have automatic backups enabled
#   ElastiCache.2 — ElastiCache for Redis clusters should have auto minor version upgrade enabled
#   ElastiCache.3 — ElastiCache for Redis replication groups should have auto failover
#   ElastiCache.4 — ElastiCache for Redis replication groups should be encrypted at rest
#   ElastiCache.5 — ElastiCache for Redis replication groups should be encrypted in transit
#   ElastiCache.6 — ElastiCache for Redis replication groups before 6.0 should use Redis AUTH
#   ElastiCache.7 — ElastiCache clusters should not use the default subnet group

# Subnet group
resource "aws_elasticache_subnet_group" "vp_test" {
  name       = "vp-test-cache-subnet"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# Redis replication group — no encryption, no failover, no auth
resource "aws_elasticache_replication_group" "vp_test" {
  replication_group_id = "vp-test-insecure-redis"
  description          = "VectorPlane E2E test — intentionally non-compliant"

  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.vp_test.name
  engine_version       = "7.0"

  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
  automatic_failover_enabled = false
  auto_minor_version_upgrade = false
  snapshot_retention_limit   = 0

  # at_rest_encryption_enabled = false — triggers ElastiCache.4
  # transit_encryption_enabled = false — triggers ElastiCache.5
  # automatic_failover_enabled = false — triggers ElastiCache.3
  # auto_minor_version_upgrade = false — triggers ElastiCache.2
  # snapshot_retention_limit = 0 — triggers ElastiCache.1
  # No auth_token — triggers ElastiCache.6

  tags = var.common_tags
}
