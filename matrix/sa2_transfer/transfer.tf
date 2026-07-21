# matrix/sa2_transfer — violating AWS Transfer Family SFTP connector authored BARE:
#   Transfer.3 — logging_role OMITTED: connector has no CloudWatch logging role
#   Transfer.6 — security_policy_name OMITTED (falls back to a non-current default
#                policy): connector not pinned to a strong/current TLS-SSH policy
# access_role is the companion IAM role; sftp_config carries a valid trusted host key
# and a Secrets Manager secret (required by the API) holding the SFTP credentials.

resource "aws_secretsmanager_secret" "sftp" {
  name = "vp-sa2-sftp-${random_id.s.hex}"
}

resource "aws_secretsmanager_secret_version" "sftp" {
  secret_id     = aws_secretsmanager_secret.sftp.id
  secret_string = jsonencode({ Username = "vpuser", Password = "vp-sa2-${random_id.s.hex}" })
}

resource "aws_transfer_connector" "vp" {
  access_role = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  url         = "sftp://sftp.vp-sa2-${random_id.s.hex}.example.com"

  sftp_config {
    user_secret_id    = aws_secretsmanager_secret.sftp.arn
    trusted_host_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD43I9KXWsQOefA7INHZDqPnqEvXseU8DtdOhW5UG4basRYetSyw+67SMwaEwK5qVILW71qWJbRx3OABmc3Tb5xii9fNV1XzM8njS09OlhZ7m9hbpnVrV27yjA0zaEQ5d86eFbQFD4o4PJKRLiYbc0PI+E9cc/x9vwsFFKLTf+38IBilhPtQ/3MY4atTnr2TALw6RoeHR2D0S1gegXAUBNQoXujjmVeL8l0DemDdGit2dNatfQdd+HesouuDf68gkadL6GZHiLHIIqU7fYtF+dxfMDrx2ojVZYbEtW7aR3DK3SdP710C3V4uEhYamW772COJvmkAtMVPwAHaCuBdpeF"]
  }
}
