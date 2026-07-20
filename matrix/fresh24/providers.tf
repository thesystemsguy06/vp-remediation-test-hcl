terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }
  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "matrix/fresh24/terraform.tfstate"
    region  = "us-east-1"
    profile = "vp-target-user"
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "vp-target-user"
  default_tags { tags = { Project = "vectorplane-e2e-test", Wave = "matrix-fresh24" } }
}
resource "random_id" "s" { byte_length = 4 }
