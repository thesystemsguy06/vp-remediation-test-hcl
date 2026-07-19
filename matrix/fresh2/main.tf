# matrix/fresh2 — VIOLATING resources (block/attr absent or wrong) for net-new
# controls not covered by fresh1. Cheap/free, oracle-verified FIXED before deploy.

# ECS.1 + ECS.17 (network_mode -> awsvpc) + ECS.3 (pid_mode -> task) + ECS.18 (volume block)
resource "aws_ecs_task_definition" "vp_ecs" {
  family       = "vp-fresh2-ecs-${random_id.s.hex}"
  network_mode = "bridge"
  pid_mode     = "host"
  container_definitions = jsonencode([{
    name      = "app"
    image     = "public.ecr.aws/nginx/nginx:latest"
    essential = true
    memory    = 128
  }])
}

# EFS.1 — unencrypted file system (encryption is create-time; fix forces replace of an empty FS)
resource "aws_efs_file_system" "vp_efs" {
  creation_token = "vp-fresh2-efs-${random_id.s.hex}"
  encrypted      = false
}

# SSM.7 — SSM document without KMS block sharing / encryption (sh_ssm_7 SUB_RESOURCE)
resource "aws_ssm_document" "vp_ssm" {
  name          = "vp-fresh2-ssm-${random_id.s.hex}"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2"
    description   = "vp fresh2 test document"
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "run"
      inputs = { runCommand = ["echo hi"] }
    }]
  })
}

# DynamoDB.1 — table not encrypted with a customer KMS key (KMS-input fix)
resource "aws_dynamodb_table" "vp_ddb_kms" {
  name         = "vp-fresh2-ddbkms-${random_id.s.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# Kinesis.2 — stream not encrypted with a customer KMS key (KMS-input fix)
resource "aws_kinesis_stream" "vp_kinesis_kms" {
  name        = "vp-fresh2-kinkms-${random_id.s.hex}"
  shard_count = 1
}
