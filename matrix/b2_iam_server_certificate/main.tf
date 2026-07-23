# IAM.26: expired SSL/TLS certificates in IAM should be removed -> upload an EXPIRED cert
resource "aws_iam_server_certificate" "insecure" {
  name             = "vp-insecure-expired-cert-b2"
  certificate_body = file("${path.module}/cert.pem")
  private_key      = file("${path.module}/key.pem")
}
