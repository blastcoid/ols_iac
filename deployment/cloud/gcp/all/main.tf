module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.2.1"
  project_id    = "<PROJECT ID>"
  prefix        = "test-sa"
  names         = ["first", "second"]
  project_roles = [
    "project-foo=>roles/viewer",
    "project-spam=>roles/storage.objectViewer",
  ]
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2"

  project_id         = "<PROJECT ID>"
  location           = "europe"
  keyring            = "sample-keyring"
  keys               = ["foo", "spam"]
  set_owners_for     = ["foo", "spam"]
  owners = [
    "group:one@example.com,group:two@example.com",
    "group:one@example.com",
  ]
}