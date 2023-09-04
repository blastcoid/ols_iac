# # Create kubectl provider
terraform {
  required_providers {
    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

# provider "kubectl" {
#   config_path = "~/.kube/config"
# }
