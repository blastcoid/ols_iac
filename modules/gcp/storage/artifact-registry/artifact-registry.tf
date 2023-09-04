resource "google_artifact_registry_repository" "repository" {
  provider               = google-beta
  location               = var.region
  repository_id          = var.repository_id
  description            = "This is the repository for ${var.repository_id} service"
  format                 = var.repository_format
  mode                   = var.repository_mode
  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    iterator = policy
    content {
      id     = policy.key
      action = policy.value.action

      dynamic "condition" {
        for_each = policy.value.condition != null ? [policy.value.condition] : []
        content {
          tag_state             = condition.value.tag_state
          tag_prefixes          = condition.value.tag_prefixes
          version_name_prefixes = condition.value.version_name_prefixes
          package_name_prefixes = condition.value.package_name_prefixes
          older_than            = condition.value.older_than
          newer_than            = condition.value.newer_than
        }
      }

      dynamic "most_recent_versions" {
        for_each = policy.value.most_recent_versions != null ? [policy.value.most_recent_versions] : []
        content {
          package_name_prefixes = most_recent_versions.value.package_name_prefixes
          keep_count            = most_recent_versions.value.keep_count
        }
      }
    }
  }
}
