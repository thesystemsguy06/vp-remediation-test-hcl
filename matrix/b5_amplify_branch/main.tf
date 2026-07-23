resource "aws_amplify_app" "app" { name = "vp-b5-amplify-72092" }
resource "aws_amplify_branch" "b" {
  app_id      = aws_amplify_app.app.id
  branch_name = "main"
}
