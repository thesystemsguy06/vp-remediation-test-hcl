data "archive_file" "fn" {
  type        = "zip"
  output_path = "${path.module}/fn_${random_id.s.hex}.zip"
  source {
    content  = "def handler(e,c): return 'ok'"
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda" {
  name = "vp-sb3-lambda-${random_id.s.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_function" "this" {
  function_name    = "vp-sb3-fn-${random_id.s.hex}"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.fn.output_path
  source_code_hash = data.archive_file.fn.output_base64sha256

  dead_letter_config {
    target_arn = "arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"
  }

  vpc_config {
    subnet_ids         = ["subnet-0dd7628650cbd31c3"]
    security_group_ids = ["sg-055114eda16cd94b1"]
  }
}
