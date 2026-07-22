# matrix/sa4_ecr — violating ECR repository authored BARE to trip:
#   ECR.1 — repositories should have image scanning (scan_on_push = false)
#   ECR.3 — repositories should have at least one lifecycle policy (none attached)
# scan_on_push is explicitly false and NO aws_ecr_lifecycle_policy is attached.
resource "aws_ecr_repository" "vp" {
  image_tag_mutability = "IMMUTABLE"
  name                 = "vp-sa4-${random_id.s.hex}"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:746210888062:key/8e81be12-deed-4aa9-ad53-51223ba4a09e"
  }
}
