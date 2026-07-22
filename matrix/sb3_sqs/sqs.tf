resource "aws_sqs_queue" "this" {
  name = "vp-sb3-sqs-${random_id.s.hex}"
}
