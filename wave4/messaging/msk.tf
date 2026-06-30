# Amazon MSK resources with intentionally non-compliant configurations
# Wave 4 — ~$5-8/day (kafka.t3.small)
#
# Triggered controls:
#   MSK.1 — MSK clusters should be encrypted in transit among broker nodes
#   MSK.2 — MSK clusters should have enhanced monitoring configured
#   MSK.3 — MSK Connect connectors should be encrypted in transit

resource "aws_msk_cluster" "vp_test" {
  cluster_name           = "vp-test-insecure-msk"
  kafka_version          = "3.5.1"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = [var.private_subnet_a_id, var.private_subnet_b_id]

    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = false
    }
  }

  enhanced_monitoring = "DEFAULT"

  # client_broker = "TLS_PLAINTEXT" — triggers MSK.1
  # in_cluster = false — triggers MSK.1
  # enhanced_monitoring = "DEFAULT" — triggers MSK.2

  tags = var.common_tags
}
