resource "aws_cloudformation_stack" "vp" {
  notification_arns = "arn:aws:sns:us-east-1:746210888062:vp-companion-856b2431"
  name              = "vp-f26-cfn-${random_id.s.hex}"
  template_body = jsonencode({
    Resources = { T = { Type = "AWS::SNS::Topic", Properties = {} } }
  })
}
