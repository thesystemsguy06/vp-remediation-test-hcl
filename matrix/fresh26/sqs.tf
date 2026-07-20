resource "aws_sqs_queue" "vp" { name = "vp-f26-sqs-${random_id.s.hex}" }
