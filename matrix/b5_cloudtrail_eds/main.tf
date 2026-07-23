resource "aws_cloudtrail_event_data_store" "eds" {
  name                           = "vp-b5-eds-72092"
  termination_protection_enabled = false
  retention_period               = 7
}
