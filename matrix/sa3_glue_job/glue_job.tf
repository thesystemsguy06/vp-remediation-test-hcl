# matrix/sa3_glue_job — Glue ETL job with NO security_configuration attached, so
# job bookmarks / CloudWatch logs / S3 data are unencrypted. Targets:
#   Glue.1 — AWS Glue jobs should have logging enabled (CloudWatch)
#   Glue.4 — AWS Glue jobs should be encrypted at rest (security_configuration)
# security_configuration is deliberately OMITTED (the insecure dimension); the
# composer's fix is to create + attach an encrypting aws_glue_security_configuration.
resource "aws_glue_job" "vp" {
  name     = "vp-sa3-glue-${random_id.s.hex}"
  role_arn = "arn:aws:iam::746210888062:role/vp-companion-856b2431"

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://vp-test-data-746210888062/glue/vp-sa3-${random_id.s.hex}.py"
    python_version  = "3"
  }

  tags = {
    Name = "vp-sa3-glue-${random_id.s.hex}"
  }
}
