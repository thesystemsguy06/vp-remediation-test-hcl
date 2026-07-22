# matrix/sd1_amplify — Amplify app authored BARE (platform=WEB, no repository) so it trips:
#   Amplify.1 — basic authentication is disabled (enable_basic_auth omitted -> false)
#   Amplify.2 — branch auto-deletion is disabled (enable_branch_auto_deletion omitted -> false)
# The composer's fix flips enable_basic_auth (+ basic_auth_credentials) and/or
# enable_branch_auto_deletion to true.
resource "aws_amplify_app" "vp" {
  name     = "vp-sd1-amplify-${random_id.s.hex}"
  platform = "WEB"
}
