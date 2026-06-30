# DynamoDB resources with intentionally non-compliant configurations
# Wave 1 — Free tier (25 GB free), no VPC dependencies
#
# Triggered controls:
#   DynamoDB.1 — Tables should automatically scale capacity with demand
#   DynamoDB.2 — Tables should have point-in-time recovery enabled
#   DynamoDB.3 — DAX clusters should be encrypted at rest
#   DynamoDB.4 — A table should be present in a backup plan
#   DynamoDB.5 — DynamoDB tables should be tagged
#   DynamoDB.6 — Tables should have deletion protection enabled
#   DynamoDB.7 — DAX clusters should be encrypted in transit

# DynamoDB table — PROVISIONED, no PITR, no deletion protection
resource "aws_dynamodb_table" "vp_test" {
  name         = "vp-test-insecure-table"
  billing_mode = "PROVISIONED"

  read_capacity  = 5
  write_capacity = 5

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = false

  # PROVISIONED without auto-scaling — triggers DynamoDB.1
  # No PITR — triggers DynamoDB.2
  # Not in a backup plan — triggers DynamoDB.4
  # No tags beyond test tags — triggers DynamoDB.5
  # deletion_protection_enabled = false — triggers DynamoDB.6

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# DAX IAM role (needed for DAX cluster)
resource "aws_iam_role" "vp_test_dax" {
  name = "vp-test-dax-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "dax.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_iam_role_policy_attachment" "vp_test_dax" {
  role       = aws_iam_role.vp_test_dax.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# DAX cluster — requires VPC subnet group (Wave 2 dependency)
# Uncomment when VPC resources are available
#
# resource "aws_dax_cluster" "vp_test" {
#   cluster_name       = "vp-test-insecure-dax"
#   iam_role_arn       = aws_iam_role.vp_test_dax.arn
#   node_type          = "dax.t3.small"
#   replication_factor = 1
#   subnet_group_name  = "NEEDS_VPC_SUBNET_GROUP"
#
#   server_side_encryption {
#     enabled = false  # DynamoDB.3
#   }
#
#   # No cluster_endpoint_encryption_type — triggers DynamoDB.7
#
#   tags = {
#     ManagedBy = "vectorplane-e2e-test"
#     Wave      = "1"
#   }
# }
