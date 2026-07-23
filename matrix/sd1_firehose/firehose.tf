# matrix/sd1_firehose — Kinesis Firehose delivery stream (extended_s3 destination) authored
# with NO server_side_encryption block, so it trips:
#   Firehose.1 — Firehose delivery streams should have server-side encryption enabled
# The composer's fix adds a server_side_encryption block (enabled = true).
resource "aws_kinesis_firehose_delivery_stream" "vp" {
  name        = "vp-sd1-firehose-${random_id.s.hex}"
  destination = "extended_s3"
  extended_s3_configuration {
    role_arn   = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
    bucket_arn = "arn:aws:s3:::vp-test-data-746210888062"
  }

  server_side_encryption {
    enabled = true
  }
}
