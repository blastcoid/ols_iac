# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-secret-manager-ssh-main"
  }
}

# Create SSH private key
resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

module "secret-manager" {
  source             = "../../../../modules/gcp/security/secret-manager"
  region             = var.region
  env                = var.env
  secret_name_prefix = "${var.unit}-${var.env}-${var.code}"
  secret_data = {
    ssh-key-main = tls_private_key.tls.private_key_pem
  }
}
