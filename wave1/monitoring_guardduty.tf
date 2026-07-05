# GuardDuty resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   GuardDuty.1 — GuardDuty should be enabled
#   GuardDuty.2 — GuardDuty filter should be tagged
#   GuardDuty.3 — GuardDuty IPSet should be tagged
#   GuardDuty.4 — GuardDuty ThreatIntelSet should be tagged
#   GuardDuty.5 — EKS Audit Log Monitoring should be enabled
#   GuardDuty.6 — Lambda Protection should be enabled
#
# NOTE: GuardDuty detector is an account+region singleton.
# If a detector already exists, this will fail. Check first with:
#   aws guardduty list-detectors

variable "common_tags_monitoring_gd" {
  default = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_guardduty_detector" "vp_test" {
  enable = true

  datasources {
    s3_logs {
      enable = false
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = false
        }
      }
    }
  }

  # EKS audit disabled — triggers GuardDuty.5
  # Lambda protection not configured — triggers GuardDuty.6

  tags = var.common_tags_monitoring_gd
}

# Filter with no tags — triggers GuardDuty.2
resource "aws_guardduty_filter" "vp_test" {
  name        = "vp-test-insecure-filter"
  action      = "ARCHIVE"
  detector_id = aws_guardduty_detector.vp_test.id
  rank        = 1

  finding_criteria {
    criterion {
      field  = "severity"
      equals = ["8"]
    }
  }

  # No tags — triggers GuardDuty.2
}

# S3 bucket for IPSet/ThreatIntelSet source files
resource "aws_s3_bucket" "vp_test_gd_lists" {
  bucket = "vp-e2e-test-gd-lists-${random_id.gd_suffix.hex}"
  tags   = var.common_tags_monitoring_gd
}

resource "random_id" "gd_suffix" {
  byte_length = 4
}

resource "aws_s3_object" "vp_test_ipset" {
  bucket  = aws_s3_bucket.vp_test_gd_lists.id
  key     = "ipset.txt"
  content = "198.51.100.0/24"
}

resource "aws_s3_object" "vp_test_threatintel" {
  bucket  = aws_s3_bucket.vp_test_gd_lists.id
  key     = "threatintel.txt"
  content = "203.0.113.0/24"
}

# IPSet with no tags — triggers GuardDuty.3
resource "aws_guardduty_ipset" "vp_test" {
  activate    = true
  detector_id = aws_guardduty_detector.vp_test.id
  format      = "TXT"
  location    = "s3://${aws_s3_bucket.vp_test_gd_lists.id}/${aws_s3_object.vp_test_ipset.key}"
  name        = "vp-test-insecure-ipset"

  # No tags — triggers GuardDuty.3
}

# ThreatIntelSet with no tags — triggers GuardDuty.4
resource "aws_guardduty_threatintelset" "vp_test" {
  activate    = true
  detector_id = aws_guardduty_detector.vp_test.id
  format      = "TXT"
  location    = "s3://${aws_s3_bucket.vp_test_gd_lists.id}/${aws_s3_object.vp_test_threatintel.key}"
  name        = "vp-test-insecure-threatintelset"

  # No tags — triggers GuardDuty.4
}
