# resource "google_project" "project" {
#   name                = "${var.unit}-${var.env}"
#   project_id          = "${var.unit}-${var.env}"
#   org_id              = var.org_id
#   auto_create_network = var.auto_create_network
# }

# Danger resource
# resource "google_project_iam_policy" "project" {
#   project     = var.project_id
#   policy_data = var.policy_data
# }

resource "google_project_service" "project" {
  for_each = var.services
  project  = var.project_id
  service  = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = var.disable_dependent_services
}


resource "google_project_iam_custom_role" "custom_roles" {
  for_each    = var.custom_roles
  role_id     = each.key
  project     = var.project_id
  title       = each.value.title
  description = "Custom role for ${each.value.title}"
  permissions = each.value.permissions
  depends_on = [ google_project_service.project ]
}