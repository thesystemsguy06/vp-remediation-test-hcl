# ECR resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   ECR.1 — Private repositories should have image scanning configured
#   ECR.2 — Private repositories should have tag immutability configured
#   ECR.3 — Repositories should have at least one lifecycle policy

resource "aws_ecr_repository" "vp_test" {
  name                 = "vp-test-insecure-repo"
  image_tag_mutability = "IMMUTABLE"

  # No image_scanning_configuration — triggers ECR.1
  # MUTABLE tags — triggers ECR.2
  # No aws_ecr_lifecycle_policy — triggers ECR.3

  tags = var.common_tags_storage
}
