resource "aws_appconfig_application" "vp_b3_env_app" {
  name = "vp-b3-env-app"
}
resource "aws_appconfig_environment" "vp_b3" {
  name           = "vp-b3-env"
  application_id = aws_appconfig_application.vp_b3_env_app.id
}
