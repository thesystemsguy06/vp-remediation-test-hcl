# sb1_docdb — violating DocumentDB cluster parameter group. The DocumentDB TLS
# control requires the "tls" parameter to be "enabled"; here it is explicitly set
# to "disabled", which is the violating state.
resource "aws_docdb_cluster_parameter_group" "vp" {
  name        = "vp-sb1-${random_id.s.hex}"
  family      = "docdb5.0"
  description = "vp sb1 violating docdb parameter group (tls disabled)"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
