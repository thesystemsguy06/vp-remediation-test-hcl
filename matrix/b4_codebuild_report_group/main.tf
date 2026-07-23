resource "aws_codebuild_report_group" "test" {
  name = "vp-b4-report-group"
  type = "TEST"
  export_config {
    type = "S3"
    s3_destination {
      bucket              = "vp-companion-logs-856b2431"
      encryption_disabled = true
      encryption_key      = ""
      packaging           = "NONE"
    }
  }
}
