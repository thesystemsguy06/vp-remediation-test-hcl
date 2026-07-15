# =============================================================================
# Crown-jewel VIOLATION MATRIX — Database category (Wave 1).
# Purpose-built violating DB resources for the families that have snippets but
# NO live SH validation yet: Aurora (aws_rds_cluster), Redshift, ElastiCache.
# Each resource intentionally trips a set of in-place-remediable SH controls.
# Flow: apply -> SH scores -> VP onboards (provenance) -> campaign -> apply fix
# -> poll SH for PASS. Zero prod impact (E2E test account).
# =============================================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_id" "s" {
  byte_length = 4
}

resource "random_password" "master" {
  length  = 20
  special = false
}

# -----------------------------------------------------------------------------
# Aurora (aws_rds_cluster) — Aurora MySQL cluster, intentionally violating:
#   - no enabled_cloudwatch_logs_exports  -> RDS.34 (Aurora audit logs)
#   - deletion_protection = false         -> RDS cluster deletion protection
#   - iam_database_authentication = false -> RDS.12 (IAM auth)
#   - copy_tags_to_snapshot = false       -> RDS cluster tag propagation
#   - backup_retention_period = 1 (low)
# storage_encrypted is create-time-only (RDS.3-class → MANUAL_REVIEW), left true
# so the cluster is otherwise realistic.
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "aurora" {
  name       = "vp-matrix-aurora-${random_id.s.hex}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier                  = "vp-matrix-aurora-${random_id.s.hex}"
  engine                              = "aurora-mysql"
  engine_version                      = "8.0.mysql_aurora.3.12.0"
  master_username                     = "vpadmin"
  master_password                     = random_password.master.result
  db_subnet_group_name                = aws_db_subnet_group.aurora.name
  skip_final_snapshot                 = true
  backup_retention_period             = 1
  deletion_protection                 = false # violation
  iam_database_authentication_enabled = false # violation -> RDS.12
  copy_tags_to_snapshot               = false # violation
  # no enabled_cloudwatch_logs_exports -> RDS.34
  apply_immediately = true
}

# -----------------------------------------------------------------------------
# Redshift (aws_redshift_cluster) — intentionally violating:
#   - publicly_accessible = true                 -> Redshift.1
#   - encrypted = false                          -> Redshift.x (at-rest)
#   - logging disabled (no logging block)        -> Redshift.4 (audit logging)
#   - enhanced_vpc_routing = false               -> Redshift.7
#   - automated_snapshot_retention_period = 0    -> Redshift.3 (backups)
#   - allow_version_upgrade = false              -> Redshift.6
#   - publicly routable default user
# -----------------------------------------------------------------------------
resource "aws_redshift_subnet_group" "rs" {
  name       = "vp-matrix-rs-${random_id.s.hex}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_redshift_cluster" "rs" {
  multi_az                             = false # Redshift.18 not in-place remediable for single-node ra3 (AWS rejects multi-AZ)
  cluster_identifier                   = "vp-matrix-rs-${random_id.s.hex}"
  database_name                        = "vpdb"
  master_username                      = "vpadmin"
  master_password                      = "${random_password.master.result}Aa1"
  node_type                            = "ra3.large"
  cluster_type                         = "single-node"
  cluster_subnet_group_name            = aws_redshift_subnet_group.rs.name
  publicly_accessible                  = false
  encrypted                            = true # ra3 forces encryption; align HCL to reality
  availability_zone_relocation_enabled = true # AWS default for ra3; align to stop drift
  enhanced_vpc_routing                 = true
  automated_snapshot_retention_period  = 7
  allow_version_upgrade                = true
  skip_final_snapshot                  = true
  apply_immediately                    = true

  # Redshift.4 audit logging (the sh_redshift_4 remediation render)
  logging {
    enable               = true
    log_destination_type = "cloudwatch"
    log_exports          = ["connectionlog", "useractivitylog", "userlog"]
  }
}

# -----------------------------------------------------------------------------
# ElastiCache (aws_elasticache_replication_group) — Redis, intentionally violating:
#   - transit_encryption_enabled = false  -> ElastiCache.x (in-transit)
#   - at_rest_encryption_enabled = false  -> ElastiCache.x (at-rest)
#   - auto_minor_version_upgrade = false  -> ElastiCache.2
#   - automatic_failover_enabled = false  -> ElastiCache.3
#   - snapshot_retention_limit = 0        -> ElastiCache.1 (backups)
# -----------------------------------------------------------------------------
resource "aws_elasticache_subnet_group" "ec" {
  name       = "vp-matrix-ec-${random_id.s.hex}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_elasticache_replication_group" "ec" {
  replication_group_id       = "vp-matrix-ec-${random_id.s.hex}"
  description                = "vp matrix elasticache violating"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  engine                     = "redis"
  subnet_group_name          = aws_elasticache_subnet_group.ec.name
  transit_encryption_enabled = false # violation
  at_rest_encryption_enabled = false # violation
  auto_minor_version_upgrade = false # violation -> ElastiCache.2
  automatic_failover_enabled = false # violation -> ElastiCache.3
  snapshot_retention_limit   = 0     # violation -> ElastiCache.1
  apply_immediately          = true
}

# -----------------------------------------------------------------------------
# RDS instance (aws_db_instance) — Postgres, intentionally violating. Live
# coverage for the RDS-instance crown-jewel family + validates the RDS.6/RDS.9
# mapping fix (RDS.6 = enhanced monitoring, RDS.9 = publish logs to CloudWatch):
#   - no monitoring_interval (0)          -> RDS.6 (enhanced monitoring)
#   - no enabled_cloudwatch_logs_exports  -> RDS.9 (publish logs)
#   - deletion_protection = false         -> RDS.8
#   - backup_retention_period = 0         -> RDS.11
#   - iam_database_authentication = false -> RDS.10
#   - auto_minor_version_upgrade = false  -> RDS.13
# -----------------------------------------------------------------------------
resource "aws_db_instance" "pg" {
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  monitoring_interval                 = 60
  monitoring_role_arn                 = "arn:aws:iam::746210888062:role/vp-rds-monitoring-role"
  identifier                          = "vp-matrix-pg-${random_id.s.hex}"
  engine                              = "postgres"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 20
  username                            = "vpadmin"
  password                            = "${random_password.master.result}Aa1"
  db_subnet_group_name                = aws_db_subnet_group.aurora.name
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  publicly_accessible                 = false
  deletion_protection                 = true  # violation -> RDS.8
  backup_retention_period             = 0     # violation -> RDS.11
  iam_database_authentication_enabled = true  # violation -> RDS.10
  auto_minor_version_upgrade          = false # violation -> RDS.13
  # no monitoring_interval             -> RDS.6 (enhanced monitoring)
  # no enabled_cloudwatch_logs_exports -> RDS.9 (publish logs)
  apply_immediately = true
}

output "matrix_database" {
  value = {
    aurora      = aws_rds_cluster.aurora.cluster_identifier
    redshift    = aws_redshift_cluster.rs.cluster_identifier
    elasticache = aws_elasticache_replication_group.ec.replication_group_id
    rds_pg      = aws_db_instance.pg.identifier
  }
}
