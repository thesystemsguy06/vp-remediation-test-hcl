resource "aws_networkfirewall_firewall_policy" "vp" {
  name = "vp-f26-nfw-${random_id.s.hex}"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}
