# fresh21 — DMS replication instance: DMS.1 (public access) + DMS.6 (auto minor version). In-place.
data "aws_vpc" "d" {
  default = true
}
data "aws_subnets" "d" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.d.id]
  }
}
resource "aws_dms_replication_subnet_group" "vp" {
  replication_subnet_group_id          = "vp-fresh21-${random_id.s.hex}"
  replication_subnet_group_description  = "vp test"
  subnet_ids                           = slice(tolist(data.aws_subnets.d.ids), 0, 2)
}
resource "aws_dms_replication_instance" "vp" {
  replication_instance_id     = "vp-fresh21-${random_id.s.hex}"
  replication_instance_class  = "dms.t3.micro"
  allocated_storage           = 5
  publicly_accessible         = true  # DMS.1 (violating)
  auto_minor_version_upgrade  = false # DMS.6 (violating)
  replication_subnet_group_id = aws_dms_replication_subnet_group.vp.replication_subnet_group_id
}
