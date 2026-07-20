resource "aws_sqs_queue" "vp" {
  name = "vp-f25-sqs-${random_id.s.hex}"
}
