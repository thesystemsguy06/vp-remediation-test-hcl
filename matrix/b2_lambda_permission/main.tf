# Lambda.1: function policies should prohibit public access -> grant public (principal "*")
data "archive_file" "fn" {
  type        = "zip"
  output_path = "${path.module}/fn.zip"
  source {
    content  = "def handler(event, context):\n    return {}\n"
    filename = "index.py"
  }
}

resource "aws_lambda_function" "insecure" {
  function_name = "vp-insecure-lambda-b2"
  role          = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  handler       = "index.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.fn.output_path
  timeout       = 5
}

# Public access: principal wildcard makes the resource policy public
resource "aws_lambda_permission" "insecure" {
  statement_id  = "vp-public-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insecure.function_name
  principal     = "*"
}
