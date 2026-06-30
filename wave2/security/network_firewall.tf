# Network Firewall resources with intentionally non-compliant configurations
# Wave 2 — VPC-dependent, costs ~$0.395/hr when deployed
#
# Triggered controls:
#   NetworkFirewall.1 — Firewalls should be deployed across multiple AZs
#   NetworkFirewall.2 — Firewall logging should be enabled
#   NetworkFirewall.3 — Firewall policy default action should be drop or forward for full packets
#   NetworkFirewall.4 — Firewall policy default stateless action for full packets should be drop or forward
#   NetworkFirewall.5 — Firewall policy default stateless action for fragmented packets should be drop or forward
#   NetworkFirewall.6 — Stateless rule group should not be empty
#   NetworkFirewall.9 — Firewalls should have deletion protection enabled

# Firewall policy — permissive defaults
resource "aws_networkfirewall_firewall_policy" "vp_test" {
  name = "vp-test-insecure-fw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]

    # aws:pass instead of aws:drop/aws:forward — triggers NetworkFirewall.4, 5
    # No stateful rule group references
  }

  tags = var.common_tags
}

# Stateless rule group — empty — triggers NetworkFirewall.6
resource "aws_networkfirewall_rule_group" "vp_test_stateless" {
  capacity = 10
  name     = "vp-test-empty-stateless-rg"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        # Needs at least one rule but we intentionally leave it minimal
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = var.common_tags
}

# Network Firewall — single AZ, no logging, no deletion protection
# NOTE: Network Firewall costs ~$0.395/hr. Uncomment only when ready to test.
#
# resource "aws_networkfirewall_firewall" "vp_test" {
#   name                = "vp-test-insecure-firewall"
#   firewall_policy_arn = aws_networkfirewall_firewall_policy.vp_test.arn
#   vpc_id              = aws_vpc.vp_test.id
#
#   delete_protection                 = false
#   firewall_policy_change_protection = false
#   subnet_change_protection          = false
#
#   # Single AZ only — triggers NetworkFirewall.1
#   subnet_mapping {
#     subnet_id = aws_subnet.vp_test_public_a.id
#   }
#
#   # delete_protection = false — triggers NetworkFirewall.9
#   # No logging — triggers NetworkFirewall.2
#
#   tags = var.common_tags
# }
#
# # To enable logging (uncomment for testing the logging control separately):
# # resource "aws_networkfirewall_logging_configuration" "vp_test" {
# #   firewall_arn = aws_networkfirewall_firewall.vp_test.arn
# #   logging_configuration {
# #     log_destination_config {
# #       log_destination = {
# #         logGroup = "/vp-test/network-firewall"
# #       }
# #       log_destination_type = "CloudWatchLogs"
# #       log_type             = "ALERT"
# #     }
# #   }
# # }
