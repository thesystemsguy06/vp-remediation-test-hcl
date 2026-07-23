resource "aws_sqs_queue" "vp_b3" {
  name = "vp-b3-public-queue"
}
resource "aws_sqs_queue_policy" "vp_b3" {
  queue_url = aws_sqs_queue.vp_b3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Sid = "pub", Effect = "Allow", Principal = "*", Action = "sqs:SendMessage", Resource = aws_sqs_queue.vp_b3.arn }]
  })
}
