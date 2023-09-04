# data source for gke cluster
# data "terraform_remote_state" "cluster" {
#   backend = "gcs"

#   config = {
#     bucket = "ols-dev-storage-gcs-tfstate"
#     prefix = "gkubernetes-engine/ols-dev-gkubernetes-engine-ols"
#   }
# }

# create gcp provider
provider "google" {
  project = "ols-platform-dev"
  region  = "asia-southeast2"
}

# create provider for helm and get credential from gke cluster
# create kubernetes provider
data "google_client_config" "current" {}

provider "kubernetes" {
  # host                   = "https://${data.terraform_remote_state.cluster.outputs.cluster_endpoint}"
  # token                  = data.google_client_config.current.access_token
  # cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_ca_certificate)
  config_path = "~/.kube/config"
  experiments {
    manifest_resource = true
  }
}

# create helm provider
provider "helm" {
  kubernetes {
    # add host endpoint with port
    # host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
    # cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_ca_certificate)
    # client_key             = base64decode(data.terraform_remote_state.cluster.outputs.cluster_client_key)
    # client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.cluster_client_certificate)
    config_path = "~/.kube/config"
  }
}

