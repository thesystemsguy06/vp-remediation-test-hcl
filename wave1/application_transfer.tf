# Transfer Family resources with intentionally non-compliant configurations
# Wave 1 — Free tier (per-protocol-hour when enabled), no VPC dependencies
#
# Triggered controls:
#   Transfer.1 — Workflows should be tagged
#   Transfer.2 — Connectors should be tagged
#   Transfer.3 — Servers should have logging enabled

# Transfer server — no logging — triggers Transfer.3
resource "aws_transfer_server" "vp_test" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
  endpoint_type          = "PUBLIC"

  # No structured_log_destinations — triggers Transfer.3

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

# Transfer workflow — no tags — triggers Transfer.1
resource "aws_transfer_workflow" "vp_test" {
  steps {
    type = "DELETE"
    delete_step_details {
      name                 = "vp-test-delete-step"
      source_file_location = "$${previous.file}"
    }
  }

  # No tags — triggers Transfer.1
}
