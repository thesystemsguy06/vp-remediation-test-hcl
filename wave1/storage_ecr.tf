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

resource "aws_ecr_lifecycle_policy" "vp_test_lifecycle_policy" {
  repository = aws_ecr_repository.vp_test.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "production"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 5 staging images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["stage", "staging"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Keep last 3 development images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev", "development"]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 4
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

