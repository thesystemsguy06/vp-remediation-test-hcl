# matrix/sb2_batch — minimal MANAGED FARGATE Batch compute environment on the companion
# VPC / subnets / security group and companion service role. Targets:
#   Batch.3 / Batch.4 — Batch compute environment logging / configuration controls
# Kept intentionally minimal; the composer supplies the missing secure attributes.
resource "aws_batch_compute_environment" "vp" {
  compute_environment_name = "vp-sb2-batch-${random_id.s.hex}"
  type                     = "MANAGED"
  # service_role omitted -> Batch uses the AWSServiceRoleForBatch service-linked role
  # (the companion role does not trust batch.amazonaws.com).

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 4
    subnets            = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
    security_group_ids = ["sg-055114eda16cd94b1"]
  }
}
