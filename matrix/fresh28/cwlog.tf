resource "aws_cloudwatch_log_group" "vp" {
  name = "vp-f28-lg-${random_id.s.hex}"
}
