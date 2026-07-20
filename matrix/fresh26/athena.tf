resource "aws_athena_workgroup" "vp" {
  name          = "vp-f26-athena-${random_id.s.hex}"
  force_destroy = true
  configuration {
    enforce_workgroup_configuration = false
    result_configuration {
      output_location = "s3://vp-test-data-746210888062/athena/"
    }
  }
}
