# RedshiftServerless.4 (no CMK), .5 (default admin username "admin"), .6 (no log export)
# Namespace only (no workgroup) = no compute cost.
resource "aws_redshiftserverless_namespace" "insecure" {
  log_exports         = ["connectionlog", "userlog"]
  kms_key_id          = "arn:aws:kms:us-east-1:746210888062:key/8e81be12-deed-4aa9-ad53-51223ba4a09e"
  namespace_name      = "vp-insecure-rss-b2"
  admin_username      = "admin"
  admin_user_password = "VpInsecure123!"
  # no kms_key_id (uses AWS-owned default) -> RS.4 fail
  # no log_exports                          -> RS.6 fail
}
