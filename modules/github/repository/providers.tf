terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.34.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}