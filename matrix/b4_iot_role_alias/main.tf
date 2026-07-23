resource "aws_iot_role_alias" "test" {
  alias    = "vp-b4-role-alias"
  role_arn = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
}
