# Transfer.7: Transfer Family profiles should be tagged -> no tags
resource "aws_transfer_profile" "insecure" {
  as2_id       = "VPINSECURE"
  profile_type = "LOCAL"
}
