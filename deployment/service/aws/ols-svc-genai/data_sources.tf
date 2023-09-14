data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ssh_key" {
  name = "/${var.unit}/${var.env}/ops/ssm/iac/ssh/SSH_KEY_MAIN"
}

data "terraform_remote_state" "all" {
  backend = "s3"
  config = {
    bucket  = "${var.unit}-${var.env}-stor-s3-tfstate"
    key     = "aws/all/${var.unit}-${var.env}-all-deployment.tfstate"
    region  = var.region
    profile = "${var.unit}-${var.env}"
  }
}

# Load secrets ciphertext from terraform.tfvars and decrypt them into plaintext
data "aws_kms_secrets" "secrets" {
  for_each = var.secrets_ciphertext
  secret {
    name    = each.key
    payload = each.value
  }
}