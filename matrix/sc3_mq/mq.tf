# sc3_mq — violating ActiveMQ broker. Targets MQ.2:
#   no logs { audit=true general=true }  (audit logging disabled)
# NOTE: MQ.3 (auto minor version upgrade) is NOT violatable — AWS rejects
# CreateBroker for ActiveMQ unless auto_minor_version_upgrade=true (enforced on
# every available engine version 5.18/5.19), so this fixture cannot exercise MQ.3.
# SINGLE_INSTANCE + mq.t3.micro keeps cost low. Sits in one companion subnet.
resource "aws_mq_broker" "vp" {
  broker_name                = "vp-sc3-mq-${random_id.s.hex}"
  engine_type                = "ActiveMQ"
  engine_version             = "5.19"
  host_instance_type         = "mq.t3.micro"
  deployment_mode            = "SINGLE_INSTANCE"
  publicly_accessible        = false
  auto_minor_version_upgrade = true
  subnet_ids                 = ["subnet-0dd7628650cbd31c3"]
  security_groups            = ["sg-055114eda16cd94b1"]
  apply_immediately          = true

  user {
    username = "vpadmin"
    password = "VpTestBrokerPass123"
  }

  logs {
    audit   = true
    general = true
  }
}
