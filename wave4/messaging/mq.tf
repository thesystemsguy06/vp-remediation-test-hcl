# Amazon MQ resources with intentionally non-compliant configurations
# Wave 4 — ~$3-5/day (mq.t3.micro)
#
# Triggered controls:
#   MQ.2 — ActiveMQ brokers should stream audit logs to CloudWatch
#   MQ.3 — Amazon MQ brokers should have automatic minor version upgrade enabled
#   MQ.4 — Amazon MQ brokers should be tagged
#   MQ.5 — ActiveMQ brokers should use active/standby deployment mode
#   MQ.6 — RabbitMQ brokers should use cluster deployment mode

# ActiveMQ broker — no audit logs, no auto upgrade, single instance
resource "aws_mq_broker" "vp_test_activemq" {
  broker_name        = "vp-test-insecure-activemq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.17.6"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  auto_minor_version_upgrade = false
  publicly_accessible        = false
  subnet_ids                 = [var.private_subnet_a_id]

  user {
    username = "admin"
    password = "insecure-password-123456"
  }

  logs {
    general = true
    audit   = false
  }

  # deployment_mode = "SINGLE_INSTANCE" — triggers MQ.5
  # audit = false — triggers MQ.2
  # auto_minor_version_upgrade = false — triggers MQ.3
  # No tags — triggers MQ.4

  # Intentionally no tags to trigger MQ.4
}

# RabbitMQ broker — single instance mode
resource "aws_mq_broker" "vp_test_rabbitmq" {
  broker_name        = "vp-test-insecure-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  auto_minor_version_upgrade = false
  publicly_accessible        = false
  subnet_ids                 = [var.private_subnet_a_id]

  user {
    username = "admin"
    password = "insecure-password-123456"
  }

  # deployment_mode = "SINGLE_INSTANCE" — triggers MQ.6 (should be CLUSTER_MULTI_AZ)
  # auto_minor_version_upgrade = false — triggers MQ.3
}
