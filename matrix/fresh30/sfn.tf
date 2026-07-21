resource "aws_sfn_state_machine" "vp" {
  name     = "vp-f30-sfn-${random_id.s.hex}"
  role_arn = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  definition = jsonencode({
    Comment = "vp", StartAt = "Done", States = { Done = { Type = "Succeed" } }
  })
}
