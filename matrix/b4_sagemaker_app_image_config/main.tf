resource "aws_sagemaker_app_image_config" "test" {
  app_image_config_name = "vp-b4-appimg-config"
  code_editor_app_image_config {}
}
