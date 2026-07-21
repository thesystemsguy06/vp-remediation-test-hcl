resource "aws_qldb_ledger" "vp" {
  name                = "vp-f29-qldb-${random_id.s.hex}"
  permissions_mode    = "STANDARD"
  deletion_protection = false
}
