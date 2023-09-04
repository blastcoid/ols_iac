resource "tls_private_key" "node_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_ssm_parameter" "ssm" {
  name        = "/${var.unit}/${var.env}/${var.code}/${split(var.feature[0], "-")[0]}/${var.unit}-${var.env}-${var.code}-${var.feature[0]}-main"
  description = "EKS Node Key for ${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  type        = var.ssm_type
  value       = tls_private_key.node_key.private_key_pem
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}-main"
    "Unit"    = var.unit
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[0]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}-main"
  public_key = tls_private_key.node_key.public_key_openssh
}