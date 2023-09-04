resource "aws_kms_key" "kms" {
  description              = "Customer managed main key on ${var.env} account"
  key_usage                = var.kms_key_usage
  deletion_window_in_days  = var.kms_deletion_window_in_days
  is_enabled               = var.kms_is_enabled
  enable_key_rotation      = var.kms_enable_key_rotation
  customer_master_key_spec = var.kms_customer_master_key_spec
  policy                   = var.kms_policy
  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[0]
  }
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  target_key_id = aws_kms_key.kms.key_id
}