resource "random_password" "secret" {
  length           = 64
  override_special = "!#$%&*@"
  min_lower        = 10
  min_upper        = 10
  min_numeric      = 10
  min_special      = 5
}

locals {
  # Service Locals
  github_secrets = {
    "GIT_SSH_PRIVATE_KEY" = data.aws_ssm_parameter.ssh_key.value
  }
  svc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "svc"
    Feature = "genai"
  }
  svc_naming_standard = "${local.svc_standard.Unit}-${local.svc_standard.Env}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_name            = "${local.svc_standard.Unit}_${local.svc_standard.Code}_${local.svc_standard.Feature}"
  # SSM Locals
  ssm_naming_standard = "/${local.svc_standard.Unit}/${local.svc_standard.Env}/${local.svc_standard.Code}/${local.svc_standard.Feature}"
  # Decrypt secrets ciphertext to plaintext and convert data aws kms secrets to map
  secret_map = { for k, v in data.aws_kms_secrets.secrets : k => v.plaintext[k] }
  secrets_merge = merge(
    local.secret_map,
    {
      "github_secret" = random_password.secret.result
    }
  )
  configs = {
    for k, v in var.configs :
    k => {
      value = v
      type  = "String"
      tier  = "Standard"
    }
  }
  secrets = {
    for k, v in local.secrets_merge :
    k => {
      value  = v
      type   = "SecureString"
      tier   = "Standard"
      key_id = data.terraform_remote_state.all.outputs.main_key_id
    }
  }
  parameters = merge(local.configs, local.secrets)
  # ECR Locals
  namespaces = ["images", "charts"]
}
