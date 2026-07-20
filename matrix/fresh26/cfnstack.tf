resource "aws_cloudformation_stack" "vp" {
  name          = "vp-f26-cfn-${random_id.s.hex}"
  template_body = jsonencode({
    Resources = { T = { Type = "AWS::SNS::Topic", Properties = {} } }
  })
}
