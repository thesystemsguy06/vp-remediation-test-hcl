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
  }

  # Backend configuration — uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "vp-e2e-test-tfstate"
  #   key    = "wave1/terraform.tfstate"
  #   region = "us-east-1"
  # }
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
