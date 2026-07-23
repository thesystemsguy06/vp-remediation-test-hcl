# RDS.19/20/21/22: event subscriptions should cover critical cluster/instance/param-group/SG events.
# Deploy a subscription with narrow coverage (only "maintenance") -> misses required critical categories.
resource "aws_db_event_subscription" "insecure" {
  name             = "vp-insecure-rds-evt-b2"
  sns_topic        = "arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"
  source_type      = "db-instance"
  event_categories = ["maintenance"]
  enabled          = true
}
