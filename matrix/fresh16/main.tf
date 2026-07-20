# matrix/fresh16 — Phase-2 cheap. Redis ElastiCache (cache.t3.micro ~$0.017/hr, torn down after):
#   ElastiCache.1 — snapshot_retention_limit = 0 (no automatic backups)
#   ElastiCache.2 — auto_minor_version_upgrade = false
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_elasticache_subnet_group" "vp" {
  name       = "vp-fresh16-${random_id.s.hex}"
  subnet_ids = slice(tolist(data.aws_subnets.default.ids), 0, 2)
}

resource "aws_elasticache_cluster" "vp" {
  cluster_id                 = "vp-fresh16-${random_id.s.hex}"
  engine                     = "redis"
  node_type                  = "cache.t3.micro"
  num_cache_nodes            = 1
  subnet_group_name          = aws_elasticache_subnet_group.vp.name
  snapshot_retention_limit   = 0     # ElastiCache.1: no automatic backups
  auto_minor_version_upgrade = false # ElastiCache.2
}
