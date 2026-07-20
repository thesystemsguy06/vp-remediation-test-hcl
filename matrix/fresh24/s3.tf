resource "aws_s3_bucket" "vp" {
  bucket = "vp-f24-s3-${random_id.s.hex}"
}
