# Unencrypted EBS volumes — triggers EC2.3
resource "aws_ebs_volume" "vp_test_data_vol" {
  availability_zone = "us-east-1a"
  size              = 20
  encrypted         = false

  tags = merge(local.common_tags, {
    Name = "vp-test-data-vol"
  })
}

resource "aws_ebs_volume" "vp_test_backup_vol" {
  availability_zone = "us-east-1a"
  size              = 50
  encrypted         = false

  tags = merge(local.common_tags, {
    Name = "vp-test-backup-vol"
  })
}
