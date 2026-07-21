# matrix/sa4_secret — violating Secrets Manager secret with NO rotation configured:
#   SecretsManager.1 — secrets should have automatic rotation enabled
#   SecretsManager.5 — secrets should have a lambda rotation schedule / recent rotation
# No aws_secretsmanager_secret_rotation resource is attached → rotation is off.
resource "aws_secretsmanager_secret" "vp" {
  name        = "vp-sa4-${random_id.s.hex}"
  description = "vp sa4 violating secret (no rotation)"
}

resource "aws_secretsmanager_secret_version" "vp" {
  secret_id     = aws_secretsmanager_secret.vp.id
  secret_string = jsonencode({ username = "admin", password = "changeme12345" })
}
