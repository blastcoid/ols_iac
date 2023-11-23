locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  ssm_naming_standard = "/${var.standard.unit}/${var.standard.env}/${var.standard.code}/${var.standard.feature}/${var.standard.sub}"
}

resource "tls_private_key" "node_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "key" {
  key_name   = local.naming_standard
  public_key = tls_private_key.node_key.public_key_openssh
}
