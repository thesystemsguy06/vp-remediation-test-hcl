# sb1_neptune — violating Neptune cluster parameter group. The Neptune audit-log
# control requires "neptune_enable_audit_log" = 1; here it is explicitly set to
# "0" (audit logging disabled), which is the violating state.
resource "aws_neptune_cluster_parameter_group" "vp" {
  name        = "vp-sb1-${random_id.s.hex}"
  family      = "neptune1.3"
  description = "vp sb1 violating neptune parameter group (audit log disabled)"

  parameter {
    name  = "neptune_enable_audit_log"
    value = "0"
  }
}
