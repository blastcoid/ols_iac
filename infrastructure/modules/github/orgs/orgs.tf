resource "github_organization_settings" "test" {
  for_each                                                     = { settings = var.orgs_settings }
  billing_email                                                = each.value.billing_email
  company                                                      = each.value.company
  blog                                                         = each.value.blog
  email                                                        = each.value.email
  twitter_username                                             = each.value.twitter_username
  location                                                     = each.value.location
  name                                                         = each.value.name
  description                                                  = each.value.description
  has_organization_projects                                    = each.value.has_organization_projects
  has_repository_projects                                      = each.value.has_repository_projects
  default_repository_permission                                = each.value.default_repository_permission
  members_can_create_repositories                              = each.value.members_can_create_repositories
  members_can_create_public_repositories                       = each.value.members_can_create_public_repositories
  members_can_create_private_repositories                      = each.value.members_can_create_private_repositories
  members_can_create_internal_repositories                     = each.value.members_can_create_internal_repositories
  members_can_create_pages                                     = each.value.members_can_create_pages
  members_can_create_public_pages                              = each.value.members_can_create_public_pages
  members_can_create_private_pages                             = each.value.members_can_create_private_pages
  members_can_fork_private_repositories                        = each.value.members_can_fork_private_repositories
  web_commit_signoff_required                                  = each.value.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = each.value.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = each.value.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = each.value.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = each.value.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = each.value.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = each.value.secret_scanning_push_protection_enabled_for_new_repositories
}
