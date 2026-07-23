# sc3_neptune — violating Neptune cluster + instance. Targets Neptune.1-9:
#   storage_encrypted=false              (encryption)
#   backup_retention_period=1            (backup)
#   deletion_protection=false            (deletion protection)
#   no enable_cloudwatch_logs_exports    (audit-log export)
#   iam_database_authentication_enabled=false (IAM auth)
#   copy_tags_to_snapshot=false          (copy tags)
# Subnet group spans the two companion subnets (2 AZs, Neptune requirement).
resource "aws_neptune_subnet_group" "vp" {
  name       = "vp-sc3-nsg-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
}

resource "aws_neptune_cluster" "vp" {
  enable_cloudwatch_logs_exports      = ["audit"]
  cluster_identifier                  = "vp-sc3-neptune-${random_id.s.hex}"
  engine                              = "neptune"
  engine_version                      = "1.3.4.0"
  neptune_subnet_group_name           = aws_neptune_subnet_group.vp.name
  vpc_security_group_ids              = ["sg-055114eda16cd94b1"]
  storage_encrypted                   = false
  backup_retention_period             = 1
  deletion_protection                 = false
  iam_database_authentication_enabled = false
  copy_tags_to_snapshot               = false
  skip_final_snapshot                 = true
  apply_immediately                   = true
}

resource "aws_neptune_cluster_instance" "vp" {
  identifier         = "vp-sc3-neptune-inst-${random_id.s.hex}"
  cluster_identifier = aws_neptune_cluster.vp.id
  engine             = "neptune"
  engine_version     = "1.3.4.0"
  instance_class     = "db.t3.medium"
  apply_immediately  = true
}
