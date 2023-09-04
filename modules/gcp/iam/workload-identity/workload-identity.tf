resource "google_service_account" "gsa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Service Account for ${var.service_account_name} service"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  project = var.project_id
  role    = var.google_service_account_role
  member  = "serviceAccount:${google_service_account.gsa.email}"
}

# Get business unit from service account name
locals {
  unit = split("-", var.service_account_name)[0]
}

# binding service account to workload identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.gsa.name
  role               = "roles/iam.workloadIdentityUser"
  members            = var.env != "prd" ? ["serviceAccount:${var.project_id}.svc.id.goog[${var.env}/${var.service_account_name}]"] : ["serviceAccount:${var.project_id}.svc.id.goog[${local.unit}/${var.service_account_name}]"]
}
