# Redshift resources with intentionally non-compliant configurations
# Wave 5 — ~$6/day (dc2.large)
#
# Triggered controls:
#   Redshift.1  — Clusters should prohibit public access
#   Redshift.2  — Connections to clusters should be encrypted in transit
#   Redshift.3  — Clusters should have automatic snapshots enabled
#   Redshift.4  — Clusters should have audit logging enabled
#   Redshift.6  — Clusters should have automatic upgrades to major versions enabled
#   Redshift.7  — Clusters should use enhanced VPC routing
#   Redshift.8  — Clusters should not use the default Admin username
#   Redshift.9  — Clusters should not use the default database name
#   Redshift.10 — Clusters should be encrypted at rest
#   Redshift.13 — Cluster snapshots should be tagged
#   Redshift.15 — Redshift security groups should allow ingress only from restricted ports

# Redshift subnet group
resource "aws_redshift_subnet_group" "vp_test" {
  name       = "vp-test-redshift-subnet"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = var.common_tags
}

# Security group for Redshift
resource "aws_security_group" "vp_test_redshift" {
  name        = "vp-test-redshift-sg"
  description = "VectorPlane E2E test Redshift SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

# Redshift cluster — public, unencrypted, default username/db, no audit logging
resource "aws_redshift_cluster" "vp_test" {
  cluster_identifier = "vp-test-insecure-redshift"
  node_type          = "dc2.large"
  number_of_nodes    = 1
  cluster_type       = "single-node"

  database_name   = "dev"
  master_username = "awsuser"
  master_password = "Insecure-Password-123"

  cluster_subnet_group_name = aws_redshift_subnet_group.vp_test.name
  vpc_security_group_ids    = [aws_security_group.vp_test_redshift.id]

  publicly_accessible                = true
  encrypted                          = false
  enhanced_vpc_routing               = false
  allow_version_upgrade              = false
  automated_snapshot_retention_period = 0
  skip_final_snapshot                = true

  # publicly_accessible = true — triggers Redshift.1
  # No require_ssl in parameter group — triggers Redshift.2
  # automated_snapshot_retention_period = 0 — triggers Redshift.3
  # No logging block — triggers Redshift.4
  # allow_version_upgrade = false — triggers Redshift.6
  # enhanced_vpc_routing = false — triggers Redshift.7
  # master_username = "awsuser" (default) — triggers Redshift.8
  # database_name = "dev" (default) — triggers Redshift.9
  # encrypted = false — triggers Redshift.10

  tags = var.common_tags
}
