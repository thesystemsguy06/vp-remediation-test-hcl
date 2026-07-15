terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }

  # Isolated state key — snippet-catalog-driven "breadth" violation root.
  # Cheap, no-VPC AWS resources stood up in maximally-violating state so the
  # corresponding auto-fixable remediation snippets fire during campaigns.
  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "matrix/breadth/terraform.tfstate"
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
      Wave      = "matrix-breadth"
      Purpose   = "securityhub-remediation-verification"
    }
  }
}
