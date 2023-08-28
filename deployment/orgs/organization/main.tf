terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "orgs/org/ols-dev-orgs-blastcoid"
  }
}

module "github_orgs_settings" {
  source = "../../../modules/github/orgs"
  orgs_settings = {
    billing_email                                                = "imam.arief.rhmn@gmail.com"
    company                                                      = "PT Blastech Digital"
    blog                                                         = "https://www.blast.co.id"
    email                                                        = "imam@blast.co.id"
    twitter_username                                             = null
    location                                                     = "Indonesia"
    name                                                         = "PT Blastech Digital"
    description                                                  = "Organization for Blastech Digital"
    has_organization_projects                                    = true
    has_repository_projects                                      = true
    default_repository_permission                                = "read"
    members_can_create_repositories                              = false
    members_can_create_public_repositories                       = false
    members_can_create_private_repositories                      = false
    members_can_create_internal_repositories                     = false
    members_can_create_pages                                     = false
    members_can_create_public_pages                              = false
    members_can_create_private_pages                             = false
    members_can_fork_private_repositories                        = true
    web_commit_signoff_required                                  = false
    advanced_security_enabled_for_new_repositories               = false
    dependabot_alerts_enabled_for_new_repositories               = false
    dependabot_security_updates_enabled_for_new_repositories     = false
    dependency_graph_enabled_for_new_repositories                = false
    secret_scanning_enabled_for_new_repositories                 = false
    secret_scanning_push_protection_enabled_for_new_repositories = false
  }
}
