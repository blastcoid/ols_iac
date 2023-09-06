# Configure the Google Cloud provider for Terraform
provider "google" {
  project = "${var.unit}-platform-${var.env}"
  region  = var.region
}

# Configure the Google Cloud provider for Terraform
provider "google-beta" {
  project = "${var.unit}-platform-${var.env}"
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  experiments {
    manifest_resource = true
  }
}

# create helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}