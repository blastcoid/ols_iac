# Danger Resource
# resource "google_organization_iam_policy" "org" {
#   org_id      = var.orgs_id
#   policy_data = "${data.google_iam_policy.admin.policy_data}"
# }

resource "google_organization_iam_custom_role" "custom_role" {
  for_each    = var.custom_roles
  role_id     = each.value.role_id
  org_id      = var.org_id
  title       = each.value.title
  description = "Custom role for ${each.value.title}"
  permissions = each.value.permissions
}

resource "google_org_policy_policy" "primary" {
  name   = var.policy_name
  parent = var.orgs_id

  dynamic "spec" {
    for_each = var.policy_spec
    content {
      inherit_from_parent = spec.value.inherit_from_parent
      reset               = spec.value.reset
      values              = spec.value.values
      dynamic "rule" {
        for_each = spec.value.rule
        content {
          allow_all = rule.value.allow_all
          deny_all  = rule.value.deny_all
          condition = rule.value.condition
        }
      }
    }
  }
}
