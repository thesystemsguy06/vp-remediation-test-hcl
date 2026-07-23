resource "aws_sagemaker_image" "vp_b3" {
  image_name = "vp-b3-image"
  role_arn   = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
}
