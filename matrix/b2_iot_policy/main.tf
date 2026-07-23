# IoT.6: IoT Core policies should be tagged -> no tags
resource "aws_iot_policy" "insecure" {
  name = "vp-insecure-iot-policy-b2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["iot:Connect"]
      Resource = ["*"]
    }]
  })
}
