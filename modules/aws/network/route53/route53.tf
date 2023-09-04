resource "aws_route53_zone" "zone" {
  name          = var.route53_zone_name
  comment       = "Zone for ${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  force_destroy = var.route53_force_destroy
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
    "Unit"    = var.unit
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[0]
  }
}
