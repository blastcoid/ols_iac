locals {
  naming_standard     = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  svc_naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.sub}-${var.standard.name}"
}

resource "aws_codestarconnections_connection" "connection" {
  name          = var.standard.sub == "svc" && var.standard.name != null ? local.svc_naming_standard : local.naming_standard
  provider_type = var.provider_type
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
