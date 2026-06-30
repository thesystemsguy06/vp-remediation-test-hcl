# SSM resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   SSM.1 — EC2 instances should be managed by SSM (needs EC2 — Wave 4)
#   SSM.2 — Instances should be compliant with patching (needs EC2 — Wave 4)
#   SSM.3 — Instances should have association compliance (needs EC2 — Wave 4)
#   SSM.4 — SSM documents should not be public

# SSM document — will be made public via CLI after apply
resource "aws_ssm_document" "vp_test" {
  name            = "vp-test-insecure-document"
  document_type   = "Command"
  document_format = "YAML"

  content = <<-DOC
    schemaVersion: "2.2"
    description: "VectorPlane E2E test document"
    mainSteps:
      - action: "aws:runShellScript"
        name: "testStep"
        inputs:
          runCommand:
            - "echo test"
  DOC

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# SSM.4: To make the document public after apply, run:
#   aws ssm modify-document-permission \
#     --name vp-test-insecure-document \
#     --permission-type Share \
#     --account-ids-to-add All
