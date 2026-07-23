resource "aws_security_group" "vp_b3" {
  ingress = [{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
  }]
  name        = "vp-b3-sg-rules"
  description = "vp b3 test open rules"
  vpc_id      = "vpc-0880cc850def460a5"
}
resource "aws_security_group_rule" "ssh_v4" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vp_b3.id
}
resource "aws_security_group_rule" "rdp_v4" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vp_b3.id
}
resource "aws_security_group_rule" "ssh_v6" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.vp_b3.id
}
