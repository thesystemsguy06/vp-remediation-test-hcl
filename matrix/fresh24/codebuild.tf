resource "aws_codebuild_project" "vp" {
  name         = "vp-f24-cb-${random_id.s.hex}"
  service_role = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  artifacts { type = "NO_ARTIFACTS" }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }
  source {
    type      = "NO_SOURCE"
    buildspec = "version: 0.2\nphases:\n  build:\n    commands:\n      - echo hi"
  }
}
