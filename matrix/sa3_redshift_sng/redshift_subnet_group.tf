# matrix/sa3_redshift_sng — Redshift subnet group spanning the two companion
# subnets (us-east-1d + us-east-1e, two AZs as Redshift requires). Targets:
#   Redshift.14 — Redshift subnet group posture
#   Redshift.16 — Redshift subnet group posture
# The subnet group itself carries the checked dimension; deploys cleanly using
# the pre-provisioned companion subnets.
resource "aws_redshift_subnet_group" "vp" {
  name       = "vp-sa3-rsng-${random_id.s.hex}"
  subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0a0a41f888339dd65"]
  tags = {
    Name = "vp-sa3-rsng-${random_id.s.hex}"
  }
}
