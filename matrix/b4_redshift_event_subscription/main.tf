resource "aws_redshift_event_subscription" "test" {
  name          = "vp-b4-redshift-sub"
  sns_topic_arn = "arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"
  source_type   = "cluster"
  severity      = "INFO"
}
