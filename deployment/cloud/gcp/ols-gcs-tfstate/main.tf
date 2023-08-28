// Configuration for Terraform state storage in Google Cloud Storage
terraform {
  backend "gcs" {
    bucket  = "ols-dev-storage-gcs-tfstate"
    prefix  = "gcp/storage/ols-dev-storage-gcs-tfstate"
  }
}

// Deploy a Google Cloud Storage bucket using the gcloud-storage module
module "gcs_tfstate" {
  source                   = "../../../../modules/gcp/storage/gcs"
  region                   = "asia-southeast2"
  unit                     = "ols"
  env                      = "dev"
  code                     = "storage"
  feature                  = ["gcs-tfstate"]
  force_destroy            = true
  public_access_prevention = "enforced"
}
