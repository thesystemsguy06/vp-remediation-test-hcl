resource "aws_sfn_state_machine" "vp" {
  name     = "vp-f30-sfn-${random_id.s.hex}"
  role_arn = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  definition = jsonencode({
    Comment = "vp", StartAt = "Done", States = { Done = { Type = "Succeed" } }
  })

  logging_configuration {
    log_destination        = "arn:aws:logs:us-east-1:746210888062:log-group:/vp/companion/856b2431"
    include_execution_data = true
    level                  = "ALL"
  }
}
