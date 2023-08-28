terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "orgs/project/ols-dev-project-ols-platform"
  }
}

data "google_project" "curent" {}

module "gcp_project" {
  source     = "../../../../modules/gcp/orgs/project"
  project_id = data.google_project.curent.project_id
  services = {
    iam              = "iam.googleapis.com",
    gcs              = "storage.googleapis.com"
    cloud_dns        = "dns.googleapis.com",
    gce              = "compute.googleapis.com",
    gke              = "container.googleapis.com",
    secret_manager   = "secretmanager.googleapis.com",
    kms              = "cloudkms.googleapis.com",
    resource_manager = "cloudresourcemanager.googleapis.com"
  }
  custom_roles = {
    devops = {
      title = "DevOps"
      permissions = [
        "compute.instances.get",
        "compute.instances.list",
        "container.clusters.get",
        "container.clusters.list",
        "storage.buckets.get",
        "storage.buckets.list",
        "cloudbuild.builds.get",
        "cloudbuild.builds.list",
        "compute.networks.get",
        "compute.networks.list",
        "compute.firewalls.get",
        "compute.firewalls.list",
        "secretmanager.secrets.get",
        "secretmanager.secrets.list",
        "cloudkms.cryptoKeys.get",
        "cloudkms.cryptoKeys.list"
      ]
    },
    quality_engineer = {
      title = "Quality Engineer"
      permissions = [
        "compute.instances.get",
        "container.clusters.get",
        "storage.buckets.get",
        "cloudbuild.builds.get",
        "logging.logEntries.list",
        "monitoring.alertPolicies.get",
        "monitoring.dashboards.get"
      ]
    },
    backend = {
      title = "Backend"
      permissions = [
        "compute.instances.get",
        "storage.buckets.get",
        "pubsub.topics.get",
        "pubsub.subscriptions.get",
        "datastore.entities.get",
        "redis.instances.get"
      ]
    },
    frontend = {
      title = "Frontend"
      permissions = [
        "storage.buckets.get",
        "storage.objects.get",
        "storage.objects.list",
        "storage.objects.create",
        "storage.objects.delete",
        "firebase.projects.get"
      ]
    },
    security_engineer = {
      title = "Security Engineer"
      permissions = [
        "compute.firewalls.get",
        "compute.firewalls.list",
        "secretmanager.secrets.get",
        "secretmanager.secrets.list",
        "cloudkms.cryptoKeys.get",
        "cloudkms.cryptoKeys.list",
        "iam.serviceAccounts.get",
        "iam.serviceAccounts.list"
      ]
    }
  }
}

module "github_project" {
  source                  = "../../../../modules/github/project"
  github_token_ciphertext = var.github_token_ciphertext
  project_name            = "${var.unit}-platform"
  owner_id                = "O_kgDOCIecxQ"
}
