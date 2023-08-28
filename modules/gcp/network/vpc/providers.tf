# Configure the Google Cloud provider for Terraform
provider "google" {
  project     = var.project_id
  region      = var.region
}
