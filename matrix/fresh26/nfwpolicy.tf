resource "aws_networkfirewall_firewall_policy" "vp" {
  name = "vp-f26-nfw-${random_id.s.hex}"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 100
      resource_arn = "arn:aws:network-firewall:us-east-1:746210888062:stateless-rulegroup/vp-companion-nfw-rg"
    }
  }
}
