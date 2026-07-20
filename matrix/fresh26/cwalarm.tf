resource "aws_cloudwatch_metric_alarm" "vp" {
  alarm_actions       = ["arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"]
  alarm_name          = "vp-f26-alarm-${random_id.s.hex}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
}
