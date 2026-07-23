resource "aws_iam_role_policy_attachment" "test" {
  role       = "vp-companion-856b2431"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudShellFullAccess"
}
