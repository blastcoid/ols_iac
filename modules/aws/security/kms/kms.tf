# Local Variables
# ---------------
# Concatenating different elements to form a standard naming convention for KMS keys.
locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
}

# AWS KMS Key Resource
# --------------------
# This section sets up a customer-managed AWS KMS key with various attributes and configurations.
# It includes key usage, deletion window, key rotation, and tagging following a standard naming convention.
resource "aws_kms_key" "key" {
  description              = "Customer managed main key on ${var.standard.env} account"
  key_usage                = var.kms_key_usage
  deletion_window_in_days  = var.kms_deletion_window_in_days
  is_enabled               = var.kms_is_enabled
  enable_key_rotation      = var.kms_enable_key_rotation
  customer_master_key_spec = var.kms_customer_master_key_spec
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.env
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
  }
}

# AWS KMS Key Policy Resource
# ---------------------------
# This section attaches a key policy to the created KMS key. 
# The policy is specified as a JSON-encoded document.
resource "aws_kms_key_policy" "policy" {
  key_id = aws_kms_key.key.id
  policy = jsonencode(var.kms_policy)
}

# AWS KMS Key Alias Resource
# --------------------------
# This section creates an alias for the KMS key.
# The alias provides a more human-readable way to manage the key.
resource "aws_kms_alias" "alias" {
  name          = "alias/${local.naming_standard}"
  target_key_id = aws_kms_key.key.key_id
}
