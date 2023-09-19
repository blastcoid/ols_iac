resource "kubernetes_manifest" "manifest" {
  count    = var.cloud_provider == "gcp" && var.create_managed_certificate ? 1 : 0
  manifest = yamldecode(templatefile("${path.module}/managed-cert.yaml", { feature = var.standard.feature, env = var.standard.env, namespace = local.namespace, dns_name = var.dns_name }))
}

resource "google_service_account" "gsa" {
  count        = var.cloud_provider == "gcp" && var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = local.helm_naming_standard
  display_name = "Service Account for helm ${local.helm_naming_standard}"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  count   = var.cloud_provider == "gcp" && var.create_service_account ? length(var.google_service_account_role) : 0
  project = var.project_id
  role    = var.google_service_account_role[count.index]
  member  = "serviceAccount:${google_service_account.gsa[0].email}"
}

# binding service account to service account token creator
resource "google_service_account_iam_binding" "token_creator" {
  count              = var.cloud_provider == "gcp" && var.create_service_account && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = var.standard.feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.helm_naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-repo-server]",
  ]
}

# binding service account to workload identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.cloud_provider == "gcp" && var.create_service_account && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.workloadIdentityUser"
  members = var.standard.feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.helm_naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-repo-server]",
  ]
}