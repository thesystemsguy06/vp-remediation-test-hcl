terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in the shared E2E state bucket, isolated key for the P0 module.
  # NOTE: no `profile` here (unlike wave1-5). The E2E harness supplies credentials
  # via AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env vars (sourced from AWS Secrets
  # Manager through e2e/config.py), so terraform runs unattended without a named
  # local AWS profile.
  backend "s3" {
    bucket = "vp-test-data-746210888062"
    key    = "p0/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "vectorplane-e2e-test"
      ManagedBy = "terraform"
      Wave      = "p0"
    }
  }
}
