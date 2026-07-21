resource "aws_glue_job" "vp" {
  name     = "vp-f33-glue-${random_id.s.hex}"
  role_arn = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  command {
    name            = "pythonshell"
    script_location = "s3://vp-test-data-746210888062/glue/script.py"
    python_version  = "3.9"
  }
}
