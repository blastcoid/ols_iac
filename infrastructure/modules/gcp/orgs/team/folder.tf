# Top-level folder under an organization.
resource "google_folder" "divisions" {
  for_each     = var.divisions
  display_name = each.key
  parent       = var.organization_id
}

# Folder nested under another folder.
resource "google_folder" "sub" {
  for_each     = var.divisions
  display_name = each.value.display_name
  parent       = each.key
}

resource "google_folder_iam_policy" "folder" {
  for_each    = google_folder.department
  folder      = each.value.id
  policy_data = var.policy_data
}

resource "google_org_policy_policy" "primary" {
  for_each = var.divisions
  name     = each.value.display_name
  parent   = each.key

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
