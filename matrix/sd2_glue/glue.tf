resource "aws_glue_catalog_database" "vp" {
  name = "vp_sd2_db_${random_id.s.hex}"
}

resource "aws_glue_crawler" "vp" {
  name          = "vp-sd2-crawler-${random_id.s.hex}"
  role          = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  database_name = aws_glue_catalog_database.vp.name

  s3_target {
    path = "s3://vp-test-data-746210888062/x"
  }

  # VIOLATING: no security_configuration (Glue crawler not configured with a
  # security configuration -> CloudWatch/S3 encryption at rest disabled)
}
