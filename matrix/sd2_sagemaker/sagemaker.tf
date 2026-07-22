resource "aws_sagemaker_notebook_instance" "vp" {
  name          = "vp-sd2-nb-${random_id.s.hex}"
  role_arn      = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  instance_type = "ml.t3.medium"

  # VIOLATING: SageMaker.1 (direct internet access) + SageMaker.3 (root access)
  direct_internet_access = "Enabled"
  root_access            = "Enabled"
}
