resource "aws_s3_bucket" "src" { bucket = "vp-b5-ds-src-72092" }
resource "aws_s3_bucket" "dst" { bucket = "vp-b5-ds-dst-72092" }
resource "aws_iam_role" "ds" {
  name = "vp-b5-datasync-72092"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "datasync.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "ds" {
  role = aws_iam_role.ds.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["s3:*"], Resource = ["*"] }]
  })
}
resource "aws_datasync_location_s3" "src" {
  s3_bucket_arn = aws_s3_bucket.src.arn
  subdirectory  = "/"
  s3_config { bucket_access_role_arn = aws_iam_role.ds.arn }
}
resource "aws_datasync_location_s3" "dst" {
  s3_bucket_arn = aws_s3_bucket.dst.arn
  subdirectory  = "/"
  s3_config { bucket_access_role_arn = aws_iam_role.ds.arn }
}
resource "aws_datasync_task" "t" {
  name                     = "vp-b5-datasync-72092"
  source_location_arn      = aws_datasync_location_s3.src.arn
  destination_location_arn = aws_datasync_location_s3.dst.arn
}
