# matrix/sa2_athena — violating Athena workgroup authored BARE:
#   Athena.3 — result_configuration has NO encryption_configuration: query results
#              are not encrypted at rest
#   Athena.4 — enforce_workgroup_configuration = false: clients can override the
#              workgroup's (unencrypted) settings; metrics also disabled
# A companion S3 bucket backs the query-results output location.

resource "aws_s3_bucket" "results" {
  bucket        = "vp-sa2-athena-${random_id.s.hex}"
  force_destroy = true
}

resource "aws_athena_workgroup" "vp" {
  publish_cloudwatch_metrics_enabled = true
  name                               = "vp-sa2-${random_id.s.hex}"
  force_destroy                      = true

  configuration {
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.results.id}/output/"
    }
  }
}
