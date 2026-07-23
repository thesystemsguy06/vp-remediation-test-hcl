# Violating S3 bucket for the aws_s3_bucket control family. A bare bucket lacks
# versioning / KMS encryption / access-logging / lifecycle / SSL-only policy and
# bucket-level public-access-block, so it fails the corresponding S3.* controls.
# The composer's SUB_RESOURCE fixes ADD each missing companion (create-if-absent),
# which apply cleanly against the untouched bucket.
resource "aws_s3_bucket" "insecure" {
  bucket        = "vp-rtest-s3-${random_id.s.hex}"
  force_destroy = true
}
