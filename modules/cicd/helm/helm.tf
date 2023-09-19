# Create namespace
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  helm_naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.feature}-${var.standard.sub}"
  namespace       = var.create_namespace ? kubernetes_namespace.namespace[0].metadata[0].name : var.namespace
}

resource "helm_release" "helm" {
  name       = "${var.standard.unit}-${var.standard.sub}"
  repository = var.repository
  chart      = var.chart
  values = length(var.values) > 0 ? sensitive([
    "${templatefile(
      "helm/${var.standard.sub}.yaml",
      {
        service_account_name = local.helm_naming_standard
        unit                 = var.standard.unit
        code                 = var.standard.code
        env                  = var.standard.env
        feature              = var.standard.feature
        dns_name             = var.dns_name
        service_account_annotation = var.cloud_provider == "gcp" && var.create_service_account ? google_service_account.gsa[0].email : (
          var.cloud_provider == "aws" && var.create_service_account ? aws_iam_role.role[0].arn : null
        )
        extra_vars = var.extra_vars
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
    service_account_name = local.helm_naming_standard,
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
    service_account_name = local.helm_naming_standard,
    namespace            = local.namespace,
    dns_name             = var.dns_name
    extra_vars           = var.extra_vars
  })
  depends_on = [helm_release.helm]
}

