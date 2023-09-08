# Create namespace
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
  namespace = var.create_namespace ? kubernetes_namespace.namespace[0].metadata[0].name : var.namespace
}

resource "kubernetes_manifest" "manifest" {
  count    = var.create_managed_certificate ? 1 : 0
  manifest = yamldecode(templatefile("${path.module}/managed-cert.yaml", { feature = var.standard.feature, env = var.standard.env, namespace = local.namespace, dns_name = var.dns_name }))
}

resource "google_service_account" "gsa" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = local.naming_standard
  display_name = "Service Account for helm ${local.naming_standard}"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  count   = var.create_service_account ? length(var.google_service_account_role) : 0
  project = var.project_id
  role    = var.google_service_account_role[count.index]
  member  = "serviceAccount:${google_service_account.gsa[0].email}"
}

# binding service account to service account token creator
resource "google_service_account_iam_binding" "token_creator" {
  count              = var.create_service_account && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = var.standard.feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-repo-server]",
  ]
}

# binding service account to workload identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.create_service_account && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.workloadIdentityUser"
  members = var.standard.feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.feature}-repo-server]",
  ]
}

resource "helm_release" "helm" {
  name       = "${var.standard.unit}-${var.standard.feature}"
  repository = var.repository
  chart      = var.chart
  values = length(var.values) > 0 ? sensitive([
    "${templatefile(
      "${replace(var.standard.feature, "-", "_")}/values.yaml",
      {
        service_account_name       = local.naming_standard
        unit                       = var.standard.unit
        code                       = var.standard.code
        env                        = var.standard.env
        feature                    = var.standard.feature
        dns_name                   = var.dns_name
        service_account_annotation = var.create_service_account ? google_service_account.gsa[0].email : null
        extra_vars                 = var.extra_vars
      }
      )
    }"
  ]) : []
  namespace = local.namespace
  lint      = true
  dynamic "set" {
    for_each = length(var.helm_sets) > 0 ? {
      for helm_key, helm_set in var.helm_sets : helm_key => helm_set
    } : {}
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = length(var.helm_sets_sensitive) > 0 ? {
      for helm_key, helm_set_sensitive in var.helm_sets_sensitive : helm_key => helm_set_sensitive
    } : {}
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
    }
  }
  dynamic "set_list" {
    for_each = length(var.helm_sets_list) > 0 ? {
      for helm_key, helm_set_list in var.helm_sets_list : helm_key => helm_set_list
    } : {}
    content {
      name  = set_list.value.name
      value = set_list.value.value
    }
  }
}

resource "kubernetes_manifest" "after_helm_manifest" {
  count = var.after_helm_manifest != null ? 1 : 0
  manifest = yamldecode(templatefile("${replace(var.standard.feature, "-", "_")}/${var.after_helm_manifest}", {
    unit                 = var.standard.unit
    env                  = var.standard.env
    code                 = var.standard.code
    feature              = var.standard.feature
    service_account_name = local.naming_standard,
    namespace            = local.namespace,
    dns_name             = var.dns_name
    extra_vars           = var.extra_vars
  }))
  depends_on = [helm_release.helm]
}

resource "kubectl_manifest" "after_crd_installed" {
  count = var.after_crd_installed != null ? 1 : 0
  yaml_body = templatefile("${replace(var.standard.feature, "-", "_")}/${var.after_crd_installed}", {
    unit                 = var.standard.unit
    env                  = var.standard.env
    code                 = var.standard.code
    feature              = var.standard.feature
    service_account_name = local.naming_standard,
    namespace            = local.namespace,
    dns_name             = var.dns_name
    extra_vars           = var.extra_vars
  })
  depends_on = [helm_release.helm]
}

