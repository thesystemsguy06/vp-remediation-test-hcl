resource "aws_sns_topic" "vp_b3" {
  name = "vp-b3-public-topic"
}
resource "aws_sns_topic_policy" "vp_b3" {
  arn = aws_sns_topic.vp_b3.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Sid = "pub", Effect = "Allow", Principal = "*", Action = "SNS:Publish", Resource = aws_sns_topic.vp_b3.arn }]
  })
}
