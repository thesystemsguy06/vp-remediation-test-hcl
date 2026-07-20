# fresh20 — SageMaker notebook to trip SageMaker.1 (direct internet), .3 (root access), .8 (platform).
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "nb" {
  name               = "vp-fresh20-${random_id.s.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_sagemaker_notebook_instance" "vp" {
  name                   = "vp-fresh20-${random_id.s.hex}"
  role_arn               = aws_iam_role.nb.arn
  instance_type          = "ml.t3.medium"
  direct_internet_access = "Enabled" # SageMaker.1 (violating)
  root_access            = "Enabled" # SageMaker.3 (violating)
}
