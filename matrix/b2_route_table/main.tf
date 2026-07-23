# EC2.42: route tables should be tagged -> deploy WITHOUT tags
resource "aws_route_table" "insecure" {
  vpc_id = "vpc-0880cc850def460a5"
}
