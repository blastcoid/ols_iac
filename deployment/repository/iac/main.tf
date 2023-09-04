terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "repository/ols-dev-github-repository-iac"
  }
}

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-kms-main"
  }
}

# Decrypt github secret using kms cryptokey
data "google_kms_secret" "github_secret" {
  crypto_key = data.terraform_remote_state.kms_cryptokey.outputs.security_cryptokey_id
  ciphertext = var.github_secret_ciphertext
}

module "github_repository" {
  source                 = "../../../modules/github/repository"
  env                    = var.env
  repository_name        = "${var.unit}_${var.feature}"
  repository_readme      = "This is the repository for ${var.unit}_${var.feature}"
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = true
  auto_init              = true
  gitignore_template     = "Terraform"
  license_template       = "apache-2.0"
  security_and_analysis = {
    advanced_security = {
      status = "enabled"
    }
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }
  topics               = ["terraform", "iac", "devops", "gcp", "aws", "argocd", "kubernetes"]
  vulnerability_alerts = true
  # list_of_protect_branch = ["main", "dev", "stg"]
  # enforce_admins         = false
  # required_pull_request_reviews = {
  #   require_code_owner_reviews      = false
  #   required_approving_review_count = 1
  #   bypass_pull_request_allowances = {
  #     users = ["greyhats13"]
  #     teams = ["devops"]
  #     apps  = ["github-actions"]
  #   }
  # }
  # restrictions = {
  #   users = ["greyhats13"]
  #   teams = ["devops"]
  #   apps  = ["github-actions"]
  # }
  webhooks = {
    atlantis = {
      configuration = {
        url          = "https://atlantis.dev.ols.blast.co.id/events"
        content_type = "json"
        insecure_ssl = false
        secret       = data.google_kms_secret.github_secret.plaintext
      }
      active = true
      events = ["push", "pull_request", "pull_request_review", "issue_comment"]
    }
    argocd = {
      configuration = {
        url          = "https://argocd.dev.ols.blast.co.id/api/webhook"
        content_type = "json"
        insecure_ssl = false
        secret       = data.google_kms_secret.github_secret.plaintext
      }
      active = true
      events = ["push"]
    }
  }
  teams_permission = {
    technology = "pull"
    devops     = "triage"
  }
}
