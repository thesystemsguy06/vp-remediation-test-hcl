# matrix/sa4_dms — violating DMS source endpoint. Authored BARE so it trips MANY
# SecurityHub DMS controls at once:
#   DMS.9  — endpoint should use SSL (ssl_mode OMITTED → defaults "none", no TLS)
#   DMS.10 — DMS endpoints for Neptune databases should have IAM auth (N/A engine, still evaluated)
#   DMS.11 — endpoint should have TLS/SSL (ssl_mode none)
#   DMS.12 — endpoint should have SSL configured for connections
# ssl_mode is deliberately OMITTED (defaults to "none") so the composer can inject it.
resource "aws_dms_endpoint" "vp" {
  endpoint_id   = "vp-sa4-${random_id.s.hex}"
  endpoint_type = "source"
  engine_name   = "mysql"
  server_name   = "example.com"
  port          = 3306
  username      = "admin"
  password      = "changeme12345"
  database_name = "testdb"
}
