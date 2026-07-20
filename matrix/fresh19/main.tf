data "aws_vpc" "d" {
  default = true
}
data "aws_subnets" "d" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.d.id]
  }
}
resource "aws_docdb_subnet_group" "vp" {
  name       = "vp-fresh19-${random_id.s.hex}"
  subnet_ids = slice(tolist(data.aws_subnets.d.ids), 0, 2)
}
resource "aws_docdb_cluster" "vp" {
  enabled_cloudwatch_logs_exports = ["audit"]
  cluster_identifier              = "vp-fresh19-${random_id.s.hex}"
  master_username                 = "vpadmin"
  master_password                 = "ChangeMe123456"
  db_subnet_group_name            = aws_docdb_subnet_group.vp.name
  storage_encrypted               = true
  skip_final_snapshot             = true
  backup_retention_period         = 7
  apply_immediately               = true
}
