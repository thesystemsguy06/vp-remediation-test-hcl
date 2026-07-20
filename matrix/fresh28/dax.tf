resource "aws_dax_cluster" "vp" {
  cluster_name       = "vp-f28-dax-${random_id.s.hex}"
  iam_role_arn       = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  node_type          = "dax.t3.small"
  replication_factor = 1
}
