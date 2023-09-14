locals {
  naming_standard     = "/${var.standard.unit}/${var.standard.env}/${var.standard.code}/${var.standard.feature}/${var.standard.sub}"
  svc_naming_standard = try("/${var.standard.unit}/${var.standard.env}/${var.standard.sub}/${var.standard.name}", null)
}

resource "aws_ssm_parameter" "configs" {
  for_each        = var.configs
  name            = local.svc_naming_standard != null ? "${local.svc_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}" : "${local.naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}"
  type            = "String"
  insecure_value  = each.value
  data_type       = var.data_type
  allowed_pattern = var.allowed_pattern
  description     = local.svc_naming_standard != null ? "Config parameter for ${local.svc_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}" : "Config parameter for ${local.naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}"
  tier            = var.tier
  tags = {
    "Name"     = upper(each.key)
    "Unit"     = var.standard.unit
    "Env"      = var.standard.env
    "Code"     = var.standard.code
    "Feature"  = var.standard.feature
    "Sub"      = var.standard.sub
    "Service"  = var.standard.name
    "Provider" = split("_", each.key)[0]
  }
}

resource "aws_ssm_parameter" "secrets" {
  for_each        = var.secrets
  name            = local.svc_naming_standard != null ? "${local.svc_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}" : "${local.naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}"
  type            = "SecureString"
  value           = each.value
  data_type       = var.data_type
  allowed_pattern = var.allowed_pattern
  description     = local.svc_naming_standard != null ? "Config parameter for ${local.svc_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}" : "Config parameter for ${local.naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}"
  key_id          = var.key_id
  tier            = var.tier
  tags = {
    "Name"     = upper(each.key)
    "Unit"     = var.standard.unit
    "Env"      = var.standard.env
    "Code"     = var.standard.code
    "Feature"  = var.standard.feature
    "Sub"      = var.standard.sub
    "Service"  = var.standard.name
    "Provider" = split("_", each.key)[0]
  }
}
