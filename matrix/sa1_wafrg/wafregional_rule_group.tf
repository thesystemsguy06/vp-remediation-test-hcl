# VIOLATING: WAF Classic Regional rule group with NO activated rules -> WAF.3
# (a rule group should have at least one rule). metric_name must be alphanumeric.
resource "aws_wafregional_rule_group" "sa1_empty" {
  name        = "sa1rg${random_id.s.hex}"
  metric_name = "sa1rg${random_id.s.hex}"
}
