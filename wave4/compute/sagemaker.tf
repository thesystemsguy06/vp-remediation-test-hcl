# SageMaker resources with intentionally non-compliant configurations
# Wave 4 — ~$3-5/day (ml.t3.medium)
#
# Triggered controls:
#   SageMaker.1 — Notebook instances should not have direct internet access
#   SageMaker.2 — Notebook instances should be launched in a custom VPC
#   SageMaker.3 — Users should not have root access to notebook instances
#   SageMaker.4 — SageMaker endpoint variants should have initial instance count > 1

resource "aws_iam_role" "vp_test_sagemaker" {
  name = "vp-test-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_sagemaker" {
  role       = aws_iam_role.vp_test_sagemaker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Notebook instance — direct internet, root access, no custom VPC
resource "aws_sagemaker_notebook_instance" "vp_test" {
  name          = "vp-test-insecure-notebook"
  role_arn      = aws_iam_role.vp_test_sagemaker.arn
  instance_type = "ml.t3.medium"

  direct_internet_access = "Enabled"
  root_access            = "Enabled"

  # No subnet_id — triggers SageMaker.2 (not in custom VPC)
  # direct_internet_access = "Enabled" — triggers SageMaker.1
  # root_access = "Enabled" — triggers SageMaker.3

  tags = var.common_tags
}
