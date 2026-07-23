# EC2.46: VPCs should be tagged -> no tags. Also no flow logs, no endpoints.
resource "aws_vpc" "insecure" {
  cidr_block = "10.77.0.0/16"
}
