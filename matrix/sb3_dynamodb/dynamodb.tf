resource "aws_dynamodb_table" "this" {
  name         = "vp-sb3-ddb-${random_id.s.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
