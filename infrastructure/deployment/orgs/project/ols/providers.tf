terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.34.0"
    }
  }
}

provider "google" {
  project = "ols-platform-dev"
  region  = "asia-southeast2"
}
