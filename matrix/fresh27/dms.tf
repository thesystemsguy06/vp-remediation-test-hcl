resource "aws_dms_endpoint" "vp" {
  endpoint_id   = "vp-f27-dms-${random_id.s.hex}"
  endpoint_type = "source"
  engine_name   = "mysql"
  server_name   = "example.com"
  port          = 3306
  username      = "admin"
  password      = "changeme12345"
  database_name = "testdb"
}
