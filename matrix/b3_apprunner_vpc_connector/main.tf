resource "aws_apprunner_vpc_connector" "vp_b3" {
  vpc_connector_name = "vp-b3-conn"
  subnets            = ["subnet-0dd7628650cbd31c3"]
  security_groups    = ["sg-055114eda16cd94b1"]
}
