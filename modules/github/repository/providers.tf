terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.36.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}