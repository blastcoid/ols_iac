resource "aws_security_group" "sg" {
  name        = "${local.naming_standard}-sg"
  description = "Security Group for ${local.naming_standard} service"
  vpc_id      = var.vpc_config.vpc_id
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
    "Service" = var.standard.name
  }
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
  description       = "Allow egress all protocol ${local.naming_standard} service"
}
