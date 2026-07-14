terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }

  # Isolated state key — separate from wave1 so this root applies with no
  # state-lock contention against any other L3 resource-type root.
  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "l3/s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "vp-target-user"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "vp-target-user"

  default_tags {
    tags = {
      Project   = "vectorplane-e2e-test"
      ManagedBy = "terraform"
      Wave      = "l3-s3-pilot"
      Purpose   = "securityhub-remediation-verification"
    }
  }
}
