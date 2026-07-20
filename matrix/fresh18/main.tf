data "aws_vpc" "d" {
  default = true
}
data "aws_subnets" "d" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.d.id]
  }
}
resource "aws_neptune_subnet_group" "vp" {
  name       = "vp-fresh18-${random_id.s.hex}"
  subnet_ids = slice(tolist(data.aws_subnets.d.ids), 0, 2)
}
resource "aws_neptune_cluster" "vp" {
  enable_cloudwatch_logs_exports      = ["audit"]
  deletion_protection                 = true
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true
  cluster_identifier                  = "vp-fresh18-${random_id.s.hex}"
  neptune_subnet_group_name           = aws_neptune_subnet_group.vp.name
  storage_encrypted                   = true
  skip_final_snapshot                 = true
  backup_retention_period             = 7
  apply_immediately                   = true
}

# Get available AZs for the region
data "aws_availability_zones" "vp_azs" {
  state = "available"
}

# Read replica instance in second AZ
resource "aws_neptune_cluster_instance" "vp_replica_1" {
  cluster_identifier = aws_neptune_cluster.vp.id
  instance_class     = aws_neptune_cluster.vp.engine == "neptune" ? "db.t3.medium" : "db.t3.medium"
  availability_zone  = data.aws_availability_zones.vp_azs.names[1]

  tags = {
    Name    = "vp-replica-1"
    Purpose = "SecurityHub-Neptune.9-Compliance"
  }
}

# Read replica instance in third AZ (if available)
resource "aws_neptune_cluster_instance" "vp_replica_2" {
  count = length(data.aws_availability_zones.vp_azs.names) > 2 ? 1 : 0

  cluster_identifier = aws_neptune_cluster.vp.id
  instance_class     = aws_neptune_cluster.vp.engine == "neptune" ? "db.t3.medium" : "db.t3.medium"
  availability_zone  = data.aws_availability_zones.vp_azs.names[2]

  tags = {
    Name    = "vp-replica-2"
    Purpose = "SecurityHub-Neptune.9-Compliance"
  }
}

