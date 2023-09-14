locals {
  naming_standard   = var.standard.code != "repo" ? "${var.standard.unit}_${var.standard.code}_${var.standard.feature}" : "${var.standard.unit}_${var.standard.feature}"
  create_repository = var.standard.env == "dev" || var.standard.env == "mstr" ? 1 : 0
  template = var.template != null ? {
    for template_key, template_value in var.template : template_key => template_value
  } : {}
}

resource "github_repository" "repository" {
  count                  = local.create_repository
  name                   = local.naming_standard
  description            = "This is the repository for ${local.naming_standard}"
  homepage_url           = var.homepage_url
  visibility             = var.visibility
  has_issues             = var.has_issues
  has_discussions        = var.has_discussions
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  delete_branch_on_merge = var.delete_branch_on_merge
  has_downloads          = var.has_downloads
  auto_init              = var.auto_init
  gitignore_template     = var.gitignore_template
  license_template       = var.license_template
  archived               = var.archived
  archive_on_destroy     = var.archive_on_destroy
  dynamic "pages" {
    for_each = var.pages != null ? [var.pages] : []
    content {
      dynamic "source" {
        for_each = pages.value.source ? [pages.value.source] : []
        content {
          branch = source.value.branch
          path   = source.value.path
        }
      }
      build_type = pages.value.build_type
      cname      = pages.value.cname
    }
  }
  dynamic "security_and_analysis" {
    for_each = var.security_and_analysis != null ? [var.security_and_analysis] : []
    content {
      dynamic "advanced_security" {
        for_each = var.visibility == "public" || security_and_analysis.value.advanced_security == null ? [] : [security_and_analysis.value.advanced_security]
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning != null ? [security_and_analysis.value.secret_scanning] : []
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null ? [security_and_analysis.value.secret_scanning_push_protection] : []
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }
  topics = var.topics
  dynamic "template" {
    for_each = local.template
    content {
      owner                = template.value.name
      repository           = template.value.source
      include_all_branches = template.value.include_all_branches
    }
  }
  vulnerability_alerts                    = var.vulnerability_alerts
  ignore_vulnerability_alerts_during_read = var.ignore_vulnerability_alerts_during_read
  allow_update_branch                     = var.allow_update_branch
}

locals {
  create_dev_branch = var.standard.env == "dev" || var.standard.env == "mstr" ? 1 : 0
  create_stg_branch = (var.standard.env == "dev" || var.standard.env == "mstr") && (github_repository.repository[0].name == "ols_iac" || github_repository.repository[0].name == "ols_helm") ? 1 : 0
}

resource "github_branch" "dev" {
  count         = local.create_dev_branch
  repository    = github_repository.repository[0].name
  branch        = var.standard.env == "mstr" ? "dev" : var.standard.env
  source_branch = var.default_branch
}

resource "github_branch" "stg" {
  count         = local.create_stg_branch
  repository    = github_repository.repository[0].name
  branch        = "stg"
  source_branch = var.default_branch
}

locals {
  enable_auto_link = var.key_prefix != null ? 1 : 0
}

resource "github_repository_autolink_reference" "autolink" {
  count               = local.enable_auto_link
  repository          = github_repository.repository[count.index].name
  key_prefix          = var.key_prefix
  target_url_template = var.target_url_template
  is_alphanumeric     = var.is_alphanumeric
}

locals {
  create_branch_protection = length(var.list_of_protect_branch) > 0 ? 1 : 0
}

resource "github_branch_protection_v3" "branch_protectionv3" {
  count          = local.create_branch_protection
  repository     = github_repository.repository[0].name
  branch         = var.list_of_protect_branch[count.index]
  enforce_admins = var.enforce_admins
  dynamic "required_status_checks" {
    for_each = var.required_status_checks != null ? [var.required_status_checks] : []
    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }
  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews != null ? [var.required_pull_request_reviews] : []
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      dismissal_users                 = required_pull_request_reviews.value.dismissal_users
      dismissal_teams                 = required_pull_request_reviews.value.dismissal_teams
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      dynamic "bypass_pull_request_allowances" {
        for_each = required_pull_request_reviews.value.bypass_pull_request_allowances != null ? [required_pull_request_reviews.value.bypass_pull_request_allowances] : []
        content {
          users = bypass_pull_request_allowances.value.users
          teams = bypass_pull_request_allowances.value.teams
          apps  = bypass_pull_request_allowances.value.apps
        }
      }
    }
  }
  dynamic "restrictions" {
    for_each = var.restrictions != null ? [var.restrictions] : []
    content {
      users = restrictions.value.users
      teams = restrictions.value.teams
      apps  = restrictions.value.apps
    }
  }
}

resource "github_repository_webhook" "webhooks" {
  for_each   = length(var.webhooks) > 0 ? var.webhooks : {}
  repository = github_repository.repository[0].name

  dynamic "configuration" {
    for_each = each.value.configuration != null ? [each.value.configuration] : []
    content {
      content_type = configuration.value.content_type
      insecure_ssl = configuration.value.insecure_ssl
      url          = configuration.value.url
      secret       = configuration.value.secret
    }
  }

  active = each.value.active

  events = each.value.events
}

resource "github_team_repository" "team_repo" {
  for_each   = length(var.teams_permission) > 0 ? var.teams_permission : {}
  team_id    = each.key
  repository = github_repository.repository[0].name
  permission = each.value
}

resource "github_repository_deploy_key" "repository_deploy_key" {
  count      = var.public_key != null ? 1 : 0
  title      = "${github_repository.repository[count.index].name}-public-key"
  repository = github_repository.repository[count.index].name
  key        = var.public_key
  read_only  = var.is_deploy_key_read_only
}

resource "kubernetes_secret_v1" "argocd" {
  count = var.argocd_namespace != null ? 1 : 0
  metadata {
    name      = replace(github_repository.repository[count.index].name, "_", "-")
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = github_repository.repository[count.index].ssh_clone_url
    sshPrivateKey = var.ssh_key
  }
}

resource "github_repository_environment" "environment" {
  count       = length(var.github_action_secrets) > 0 ? 1 : 0
  environment = "${github_repository.repository[count.index].name}_${var.standard.env}"
  repository  = github_repository.repository[count.index].name
}

resource "github_actions_environment_secret" "secret" {
  for_each        = var.github_action_secrets
  repository      = github_repository.repository[0].name
  environment     = github_repository_environment.environment[0].environment
  secret_name     = each.key
  plaintext_value = try(each.value.plaintext, each.value)
}
