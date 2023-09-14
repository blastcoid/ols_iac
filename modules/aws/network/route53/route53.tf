# Local Variables
# ---------------
# Concatenating different elements to form a standard naming convention for Route53 zones.
locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
}

# AWS Route53 Zone Resource
# -------------------------
# This section sets up an AWS Route53 DNS Zone with various attributes and configurations.
# It includes the zone name, associated comment, force_destroy option, and tagging following a standard naming convention.
resource "aws_route53_zone" "zone" {
  name          = var.route53_zone_name
  comment       = "Zone for ${local.naming_standard}"
  force_destroy = var.route53_force_destroy
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
  }
}
