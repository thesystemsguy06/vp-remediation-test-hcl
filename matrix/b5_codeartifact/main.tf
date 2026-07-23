resource "aws_codeartifact_domain" "d" { domain = "vp-b5-dom-72092" }
resource "aws_codeartifact_repository" "r" {
  repository = "vp-b5-repo-72092"
  domain     = aws_codeartifact_domain.d.domain
}
