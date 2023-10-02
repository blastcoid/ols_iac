# Create kubectl provider
terraform {
  required_providers {
    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

# Configure the Google Cloud provider for Terraform
provider "google" {
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

provider "kubectl" {
  config_path = "~/.kube/config"
}
