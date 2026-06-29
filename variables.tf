variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "vectorplane-e2e-test"
  }
}
