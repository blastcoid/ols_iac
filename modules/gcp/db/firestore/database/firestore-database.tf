data "google_project" "current" {}

locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
}

resource "google_firestore_database" "database" {
  project                     = var.project_id
  name                        = var.use_default ? "(default)" : "${local.naming_standard}-${var.standard.sub}"
  location_id                 = var.region
  type                        = var.type
  concurrency_mode            = var.concurrency_mode
  app_engine_integration_mode = var.app_engine_integration_mode
}
