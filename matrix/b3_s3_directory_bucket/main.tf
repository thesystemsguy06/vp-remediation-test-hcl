resource "aws_s3_directory_bucket" "vp_b3" {
  bucket = "vp-b3-dir--use1-az4--x-s3"
  location {
    name = "use1-az4"
  }
  force_destroy = true
}
