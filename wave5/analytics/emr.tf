# EMR resources with intentionally non-compliant configurations
# Wave 5 — ~$5-10/day (m5.xlarge)
#
# Triggered controls:
#   EMR.1 — Cluster primary nodes should not have public IP addresses
#   EMR.2 — EMR block public access setting should be enabled (account-level)
#   EMR.3 — EMR security configurations should be encrypted at rest
#   EMR.4 — EMR security configurations should be encrypted in transit

# Security configuration — no encryption
resource "aws_emr_security_configuration" "vp_test" {
  name = "vp-test-insecure-emr-config"

  configuration = jsonencode({
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = false
      # EnableInTransitEncryption = false — triggers EMR.4
      # EnableAtRestEncryption = false — triggers EMR.3
    }
  })
}

# EMR cluster — public primary node, no encryption
# NOTE: EMR creates EC2 instances which cost money. Commented out by default.
#
# resource "aws_emr_cluster" "vp_test" {
#   name          = "vp-test-insecure-emr"
#   release_label = "emr-7.0.0"
#   applications  = ["Spark"]
#
#   ec2_attributes {
#     subnet_id        = var.private_subnet_a_id
#     instance_profile = aws_iam_instance_profile.vp_test_emr.arn
#   }
#
#   master_instance_group {
#     instance_type = "m5.xlarge"
#   }
#
#   core_instance_group {
#     instance_type  = "m5.xlarge"
#     instance_count = 1
#   }
#
#   service_role          = aws_iam_role.vp_test_emr_service.arn
#   security_configuration = aws_emr_security_configuration.vp_test.name
#
#   # Public subnet may assign public IPs to primary — triggers EMR.1
#
#   tags = var.common_tags
# }

# EMR IAM roles (needed when cluster is uncommented)
resource "aws_iam_role" "vp_test_emr_service" {
  name = "vp-test-emr-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "elasticmapreduce.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_emr_service" {
  role       = aws_iam_role.vp_test_emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "vp_test_emr_ec2" {
  name = "vp-test-emr-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vp_test_emr_ec2" {
  role       = aws_iam_role.vp_test_emr_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "vp_test_emr" {
  name = "vp-test-emr-ec2-profile"
  role = aws_iam_role.vp_test_emr_ec2.name

  tags = var.common_tags
}
