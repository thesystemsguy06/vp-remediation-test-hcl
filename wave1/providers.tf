terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket  = "vp-test-data-746210888062"
    key     = "wave1/terraform.tfstate"
    region  = "us-east-1"
    profile = "vp-target-user"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "vectorplane-e2e-test"
      ManagedBy = "terraform"
    }
  }
}

variable "aws_region" {
  description = "AWS region for test resources"
  default     = "us-east-1"
}
