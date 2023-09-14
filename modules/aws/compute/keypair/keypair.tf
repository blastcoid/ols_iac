locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  ssm_naming_standard = "/${var.standard.unit}/${var.standard.env}/${var.standard.code}/${var.standard.feature}/${var.standard.sub}"
}

resource "tls_private_key" "node_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

# resource "aws_ssm_parameter" "ssm" {
#   name        = "${local.ssm_naming_standard}/SSH_KEY"
#   description = "EKS Node Key for ${local.ssm_naming_standard}"
#   type        = var.ssm_type
#   value       = tls_private_key.node_key.private_key_pem
#   tags = {
#     "Name"    = "SSH_KEY"
#     "Unit"    = var.standard.unit
#     "Env"     = var.standard.env
#     "Code"    = var.standard.code
#     "Feature" = var.standard.feature
#     "Sub"     = var.standard.sub
#   }
# }

resource "aws_key_pair" "key" {
  key_name   = local.naming_standard
  public_key = tls_private_key.node_key.public_key_openssh
}