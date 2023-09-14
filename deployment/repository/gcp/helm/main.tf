# terraform {
#   backend "gcs" {
#     bucket = "ols-dev-storage-gcs-tfstate"
#     prefix = "repository/ols-dev-github-repository-helm"
#   }
# }

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

# data "google_secret_manager_secret_version" "ssh_key" {
#   secret = "ssh-key-main"
# }

# data "tls_public_key" "public_key" {
#   private_key_pem = data.google_secret_manager_secret_version.ssh_key.secret_data
# }


module "github_repository" {
  source = "../../../../modules/github/repository"
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "repo"
    feature = "helm"
  }
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = true
  auto_init              = true
  # gitignore_template     = "Helm" # No template for helm
  license_template = "apache-2.0"
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
  topics               = ["helm", "kubernetes", "devops", "gcp", "argocd"]
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
  # webhooks = {
  #   argocd = {
  #     configuration = {
  #       url          = "https://argocd.dev.ols.blast.co.id/api/webhook"
  #       content_type = "json"
  #       insecure_ssl = false
  #       secret       = data.google_kms_secret.github_secret.plaintext
  #     }
  #     active = true
  #     events = ["push"]
  #   }
  # }
  teams_permission = {
    technology = "pull"
    devops     = "triage"
  }
  # public_key = data.tls_public_key.public_key.public_key_openssh
  # ssh_key                 = data.google_secret_manager_secret_version.ssh_key.secret_data
  is_deploy_key_read_only = false
  # argocd_namespace        = "cd"
}
