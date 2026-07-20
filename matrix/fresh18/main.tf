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
  cluster_identifier        = "vp-fresh18-${random_id.s.hex}"
  neptune_subnet_group_name = aws_neptune_subnet_group.vp.name
  storage_encrypted         = true
  skip_final_snapshot       = true
  backup_retention_period   = 1
  apply_immediately         = true
}
