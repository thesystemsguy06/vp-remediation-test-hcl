data "archive_file" "vp" {
  type        = "zip"
  output_path = "${path.module}/vp_lambda_${random_id.s.hex}.zip"
  source {
    content  = "def handler(event, context):\n    return {'ok': True}\n"
    filename = "index.py"
  }
}
resource "aws_iam_role" "lambda" {
  name = "vp-f25-lambda-${random_id.s.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_lambda_function" "vp" {
  function_name    = "vp-f25-fn-${random_id.s.hex}"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.vp.output_path
  source_code_hash = data.archive_file.vp.output_base64sha256
}
