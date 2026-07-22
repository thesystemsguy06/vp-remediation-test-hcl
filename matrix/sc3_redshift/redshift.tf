# sc3_redshift — violating single-node Redshift cluster. Targets Redshift.1/3/4/6/7/8/10:
#   encrypted=false            (at-rest encryption)
#   publicly_accessible=true   (public access)
#   no logging block           (audit logging)
#   allow_version_upgrade=false (version upgrade)
#   enhanced_vpc_routing=false  (enhanced VPC routing)
# ra3.large single-node (dc2 is retired in this region; ra3.large is the
# cheapest orderable single-node type). Subnet group spans the two
# companion subnets. VPC has an internet gateway so publicly_accessible applies.
resource "aws_redshift_subnet_group" "vp" {
  name       = "vp-sc3-rsng-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}

resource "aws_redshift_cluster" "vp" {
  cluster_identifier        = "vp-sc3-redshift-${random_id.s.hex}"
  database_name             = "vpdb"
  master_username           = "vpadmin"
  master_password           = "VpTestPass123"
  node_type                 = "ra3.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.vp.name
  vpc_security_group_ids    = ["sg-055114eda16cd94b1"]
  encrypted                 = false
  publicly_accessible       = true
  allow_version_upgrade     = false
  enhanced_vpc_routing      = false
  skip_final_snapshot       = true
}
