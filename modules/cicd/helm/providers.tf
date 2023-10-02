# Create kubectl provider
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# provider "kubectl" {
#   config_path = "~/.kube/config"
# }
