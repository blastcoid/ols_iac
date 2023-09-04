terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "service/ols/ols-dev-service-profile"
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

# Get SSH key from secret manager
data "google_secret_manager_secret_version" "ssh_key" {
  secret = "ssh-key-main"
}

# Decrypt list of secrets
data "google_kms_secret" "secrets" {
  for_each   = var.github_action_secrets_ciphertext
  crypto_key = data.terraform_remote_state.kms_cryptokey.outputs.security_cryptokey_id
  ciphertext = each.value
}

# Append SSH key to list of secrets
locals {
  updated_secrets = merge(
    data.google_kms_secret.secrets,
    { "GIT_SSH_PRIVATE_KEY" = data.google_secret_manager_secret_version.ssh_key.secret_data }
  )
}


module "github_repository" {
  source                 = "../../../modules/github/repository"
  env                    = var.env
  repository_name        = "${var.unit}_${var.code}_${var.feature}"
  repository_readme      = "This is the repository for ${var.unit}_${var.feature}"
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = false
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
  topics               = ["python", "openai", "fastapi", "service", "docker", "argocd", "gcp", "kubernetes"]
  vulnerability_alerts = true
  teams_permission = {
    technology = "pull"
    devops     = "triage"
  }
  github_action_secrets = local.updated_secrets
}

module "artifact_repository" {
  source                 = "../../../modules/gcp/storage/artifact-registry"
  region                 = var.region
  env                    = var.env
  repository_id          = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  repository_format      = "DOCKER"
  repository_mode        = "STANDARD_REPOSITORY"
  cleanup_policy_dry_run = false
  cleanup_policies = {
    "delete-prerelease" = {
      action = "DELETE"
      condition = {
        tag_state  = "TAGGED"
        tag_prefix = ["alpha", "beta"]
        older_than = "2592000s"
      }
    }
    "keep-tagged-release" = {
      action = "KEEP"
      condition = {
        tag_state             = "TAGGED"
        tag_prefixes          = ["release"]
        package_name_prefixes = ["${var.unit}-${var.env}-${var.code}-${var.feature}"]
      }
    }
    "keep-minimum-versions" = {
      action = "KEEP"
      most_recent_versions = {
        package_name_prefixes = ["${var.unit}-${var.env}-${var.code}-${var.feature}"]
        keep_count            = 5
      }
    }
  }
}

data "terraform_remote_state" "dns_blast" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-dns-blast"
  }
}


module "argocd_app" {
  source               = "../../../modules/cicd/helm"
  region               = var.region
  env                  = var.env
  repository           = "https://argoproj.github.io/argo-helm"
  chart                = "argocd-apps"
  service_account_name = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  values               = ["${file("profile/values.yaml")}"]
  namespace            = "cd"
  project_id           = "${var.unit}-platform-${var.env}"
  dns_name             = "dev.ols.blast.co.id" #trimsuffix(data.terraform_remote_state.dns_blast.outputs.dns_name, ".")
  extra_vars = {
    argocd_namespace      = "cd"
    source_repoURL        = "https://github.com/blastcoid/ols_helm"
    source_targetRevision = "HEAD"
    source_path = var.env == "dev" ? "charts/incubator/${var.unit}_${var.code}_${var.feature}" : (
      var.env == "stg" ? "charts/test/${var.unit}_${var.code}_${var.feature}" : "charts/stable/${var.unit}_${var.code}_${var.feature}"
    )
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = var.env
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}


module "workload_identity" {
  source                      = "../../../modules/gcp/iam/workload-identity"
  region                      = var.region
  env                         = var.env
  project_id                  = "${var.unit}-platform-${var.env}"
  service_account_name        = "${var.unit}-${var.code}-${var.feature}"
  google_service_account_role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

