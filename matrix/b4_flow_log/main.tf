resource "aws_flow_log" "test" {
  log_destination      = "arn:aws:s3:::vp-companion-logs-856b2431"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = "vpc-0880cc850def460a5"
}
