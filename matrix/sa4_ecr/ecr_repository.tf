# matrix/sa4_ecr — violating ECR repository authored BARE to trip:
#   ECR.1 — repositories should have image scanning (scan_on_push = false)
#   ECR.3 — repositories should have at least one lifecycle policy (none attached)
# scan_on_push is explicitly false and NO aws_ecr_lifecycle_policy is attached.
resource "aws_ecr_repository" "vp" {
  name = "vp-sa4-${random_id.s.hex}"

  image_scanning_configuration {
    scan_on_push = false
  }
}
