# Configure the Google Cloud provider for Terraform
provider "google" {
  project = "${var.unit}-platform-${var.env}"
  region  = var.region
}