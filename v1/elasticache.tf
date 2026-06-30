# ElastiCache subnet group
resource "aws_elasticache_subnet_group" "vp_test_cache_subnet_group" {
  name       = "vp-test-cache-subnet-group"
  subnet_ids = [aws_subnet.vp_test_private_subnet.id]

  tags = merge(local.common_tags, {
    Name = "vp-test-cache-subnet-group"
  })
}

# ElastiCache Redis cluster with no automatic backup and no auto failover
# — triggers ElastiCache.1, ElastiCache.3
resource "aws_elasticache_cluster" "vp_test_cache" {
  cluster_id           = "vp-test-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.vp_test_cache_subnet_group.name

  # No snapshot_retention_limit — no automatic backup
  # No at_rest_encryption_enabled — unencrypted

  tags = merge(local.common_tags, {
    Name = "vp-test-cache"
  })
}
