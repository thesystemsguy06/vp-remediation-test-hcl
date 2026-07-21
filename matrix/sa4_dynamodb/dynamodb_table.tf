# matrix/sa4_dynamodb — violating DynamoDB table authored BARE to trip:
#   DynamoDB.1 — tables should scale capacity with demand (N/A for on-demand; still evaluated)
#   DynamoDB.5 — tables should be encrypted with a customer-managed KMS key
# NO server_side_encryption block → table uses the AWS-owned default key (not a CMK).
# point_in_time_recovery is also omitted (defaults off).
resource "aws_dynamodb_table" "vp" {
  name         = "vp-sa4-${random_id.s.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
