terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

variable "common_tags" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "5"
  }
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "private_subnet_a_id" {
  type    = string
  default = ""
}

variable "private_subnet_b_id" {
  type    = string
  default = ""
}
