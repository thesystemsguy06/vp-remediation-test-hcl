# ECR repo with mutable tags and no image scanning — triggers ECR.1, ECR.2
resource "aws_ecr_repository" "vp_test_app" {
  name                 = "vp-test-app-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(local.common_tags, {
    Name = "vp-test-app-repo"
  })
}
