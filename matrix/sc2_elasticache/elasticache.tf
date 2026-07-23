# Subnet group over the 2 companion subnets (1d / 1e)
resource "aws_elasticache_subnet_group" "sng" {
  name       = "sc2-ec-sng-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}

# VIOLATING Redis replication group — no encryption at rest/in transit,
# no automatic failover, no auto minor version upgrade, no backups.
# Targets ElastiCache.3/4/5/6/7
resource "aws_elasticache_replication_group" "violating" {
  replication_group_id = "sc2-ec-${random_id.s.hex}"
  description          = "vp-e2e violating redis replication group"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.t3.micro"

  num_cache_clusters = 2
  subnet_group_name  = aws_elasticache_subnet_group.sng.name
  security_group_ids = ["sg-055114eda16cd94b1"]

  # VIOLATING settings:
  at_rest_encryption_enabled = false # ElastiCache.4
  transit_encryption_enabled = false # ElastiCache.5
  automatic_failover_enabled = true  # ElastiCache.3
  auto_minor_version_upgrade = false # ElastiCache.6
  snapshot_retention_limit   = 0     # ElastiCache.7 (no automatic backups)

  apply_immediately = true
}
