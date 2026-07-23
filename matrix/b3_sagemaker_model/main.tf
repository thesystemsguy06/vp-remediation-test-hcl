resource "aws_sagemaker_model" "vp_b3" {
  name                     = "vp-b3-model"
  execution_role_arn       = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  enable_network_isolation = false
  primary_container {
    image = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-xgboost:1.0-1"
  }
}
