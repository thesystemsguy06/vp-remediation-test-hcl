# IoT resources with intentionally non-compliant configurations
# Wave 1 — Free tier, no VPC dependencies
#
# Triggered controls:
#   IoT.1 — Security profiles should be tagged
#   IoT.2 — Mitigation actions should be tagged
#   IoT.4 — Authorizers should be tagged
#   IoT.5 — Topic rule aliases should be tagged
#   IoT.6 — Fleet indexing should be configured

resource "aws_iam_role" "vp_test_iot" {
  name = "vp-test-iot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "iot.amazonaws.com" }
    }]
  })

  tags = {
    ManagedBy = "vectorplane-e2e-test"
    Wave      = "1"
  }
}

resource "aws_iam_role_policy" "vp_test_iot" {
  name = "vp-test-iot-publish"
  role = aws_iam_role.vp_test_iot.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sns:Publish", "iot:*"]
      Resource = "*"
    }]
  })
}

# IoT topic rule — no tags — triggers IoT.5
resource "aws_iot_topic_rule" "vp_test" {
  name        = "vp_test_insecure_rule"
  enabled     = true
  sql         = "SELECT * FROM 'vp/test'"
  sql_version = "2016-03-23"

  cloudwatch_alarm {
    alarm_name   = "vp-test-iot-alarm"
    role_arn     = aws_iam_role.vp_test_iot.arn
    state_reason = "IoT rule triggered"
    state_value  = "ALARM"
  }

  # No tags — triggers IoT.5
}

# IoT policy — basic
resource "aws_iot_policy" "vp_test" {
  name = "vp-test-iot-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "iot:*"
      Resource = "*"
    }]
  })
}

# IoT thing
resource "aws_iot_thing" "vp_test" {
  name = "vp-test-insecure-thing"
}

# IoT.6 — Fleet indexing is account-level configuration
# Must be configured via aws_iot_indexing_configuration
# Uncomment to test IoT.6 (singleton resource)
#
# resource "aws_iot_indexing_configuration" "vp_test" {
#   thing_indexing_configuration {
#     thing_indexing_mode = "OFF"
#   }
#   # thing_indexing_mode = "OFF" — triggers IoT.6
# }
