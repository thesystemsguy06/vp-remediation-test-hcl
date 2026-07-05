# Elastic Beanstalk resources with intentionally non-compliant configurations
# Wave 1 — Free tier (application is free, environment may incur costs), no VPC dependencies
#
# Triggered controls:
#   ElasticBeanstalk.1 — Enhanced health reporting not configured
#   ElasticBeanstalk.2 — Managed platform updates not enabled
#   ElasticBeanstalk.3 — HTTPS not configured on load balancer

resource "aws_elastic_beanstalk_application" "vp_test" {
  name        = "vp-e2e-test-app"
  description = "VectorPlane E2E test — intentionally non-compliant"

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Environment — no enhanced health, no managed updates, no HTTPS
# NOTE: EB environment creates underlying resources (EC2, ASG, ELB)
# which may incur costs. Uncomment when ready to test.
#
# resource "aws_elastic_beanstalk_environment" "vp_test" {
#   name                = "vp-e2e-test-env"
#   application         = aws_elastic_beanstalk_application.vp_test.name
#   solution_stack_name = "64bit Amazon Linux 2023 v6.3.1 running Node.js 20"
#
#   # No enhanced health reporting — triggers ElasticBeanstalk.1
#   # No managed platform updates — triggers ElasticBeanstalk.2
#   # No HTTPS listener — triggers ElasticBeanstalk.3
#
#   tags = {
#     ManagedBy = "vectorplane-e2e-test"
#     Wave      = "1"
#   }
# }
