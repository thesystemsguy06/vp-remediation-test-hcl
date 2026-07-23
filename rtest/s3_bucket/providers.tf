terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }
  # S3 backend (authoritative state — no local/S3 divergence). Distinct rtest/ key.
  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "rtest/s3_bucket/terraform.tfstate"
    region  = "us-east-1"
    profile = "vp-target-user"
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "vp-target-user"
  # vp-rtest-* / Project=vp-rtest so the matrix teardown sweep never touches it.
  default_tags { tags = { Project = "vp-rtest", ResourceUnderTest = "aws_s3_bucket" } }
}
resource "random_id" "s" { byte_length = 4 }
