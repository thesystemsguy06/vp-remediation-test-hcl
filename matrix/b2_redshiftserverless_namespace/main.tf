# RedshiftServerless.4 (no CMK), .5 (default admin username "admin"), .6 (no log export)
# Namespace only (no workgroup) = no compute cost.
resource "aws_redshiftserverless_namespace" "insecure" {
  namespace_name      = "vp-insecure-rss-b2"
  admin_username      = "admin"
  admin_user_password = "VpInsecure123!"
  # no kms_key_id (uses AWS-owned default) -> RedshiftServerless.4 fail
  # no log_exports                          -> RedshiftServerless.6 fail
}
