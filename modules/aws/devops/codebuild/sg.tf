resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Security Group for ${var.name} service"
  vpc_id      = var.vpc_config.vpc_id
  tags        = var.standard
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
  description       = "Allow egress all protocol ${var.name} service"
}
