# EKS resources with intentionally non-compliant configurations
# Wave 5 — ~$2.40/day (cluster) + node costs
#
# Triggered controls:
#   EKS.1 — EKS cluster endpoints should not be publicly accessible
#   EKS.2 — EKS clusters should run on a supported Kubernetes version
#   EKS.3 — EKS clusters should use encrypted Kubernetes secrets
#   EKS.6 — EKS clusters should be tagged
#   EKS.7 — EKS identity provider configs should be tagged
#   EKS.8 — EKS clusters should have audit logging enabled

resource "aws_iam_role" "vp_test_eks" {
  name = "vp-test-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_eks_policy" {
  role       = aws_iam_role.vp_test_eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Security group for EKS
resource "aws_security_group" "vp_test_eks" {
  name        = "vp-test-eks-sg"
  description = "VectorPlane E2E test EKS security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vp-e2e-test-eks-sg"
  })
}

# EKS cluster — public endpoint, no encryption, no logging
resource "aws_eks_cluster" "vp_test" {
  name     = "vp-test-insecure-eks"
  role_arn = aws_iam_role.vp_test_eks.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = [var.private_subnet_a_id, var.private_subnet_b_id]
    security_group_ids      = [aws_security_group.vp_test_eks.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  # No encryption_config — triggers EKS.3
  # No enabled_cluster_log_types — triggers EKS.8
  # endpoint_public_access = true — triggers EKS.1
  # version "1.28" may be approaching EOL — triggers EKS.2

  # Intentionally no tags to trigger EKS.6

  depends_on = [aws_iam_role_policy_attachment.vp_test_eks_policy]
}
