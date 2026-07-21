resource "aws_docdb_cluster_parameter_group" "vp" {
  name   = "vp-f31-docdbpg-${random_id.s.hex}"
  family = "docdb5.0"
  parameter {
    name  = "tls"
    value = "disabled"
  }
}
