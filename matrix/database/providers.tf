terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }

  # Isolated state key — one root per crown-jewel category (the "violation matrix").
  # DB families here (Aurora / Redshift / ElastiCache) are the untested-live ones;
  # RDS-instance and DynamoDB are already SH-green from wave1.
  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "matrix/database/terraform.tfstate"
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
      Wave      = "matrix-database"
      Purpose   = "securityhub-remediation-verification"
    }
  }
}
