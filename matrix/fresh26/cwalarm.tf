resource "aws_cloudwatch_metric_alarm" "vp" {
  alarm_name          = "vp-f26-alarm-${random_id.s.hex}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
}
