# Batch.1: Batch job queues should be tagged -> no tags. Fargate CE (no instances = free).
# Omit service_role so Batch uses its service-linked role (AWSServiceRoleForBatch).
resource "aws_batch_compute_environment" "insecure" {
  compute_environment_name = "vp-insecure-batch-ce-b2b"
  type                     = "MANAGED"
  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 1
    subnets            = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
    security_group_ids = ["sg-055114eda16cd94b1"]
  }
}

resource "aws_batch_job_queue" "insecure" {
  name                 = "vp-insecure-batch-jq-b2"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.insecure.arn]
}
