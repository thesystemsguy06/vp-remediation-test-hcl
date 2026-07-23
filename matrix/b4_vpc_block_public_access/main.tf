resource "aws_vpc_block_public_access_options" "test" {
  internet_gateway_block_mode = "off"
}
