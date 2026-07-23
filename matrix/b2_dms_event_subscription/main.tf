# DMS.3: DMS event subscriptions should be tagged -> no tags
resource "aws_dms_event_subscription" "insecure" {
  name             = "vp-insecure-dms-evt-b2"
  enabled          = true
  sns_topic_arn    = "arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"
  source_type      = "replication-instance"
  event_categories = ["configuration change", "failure"]
}
