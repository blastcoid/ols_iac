# No longer support. Ref: https://stackoverflow.com/questions/73268885/unable-to-create-project-in-repository-or-organisation-using-github-rest-api
# resource "github_organization_project" "project" {
#   name = var.project_name
#   body = var.project_body
# }

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-kms-main"
  }
}

data "google_kms_secret" "github_token" {
  crypto_key = data.terraform_remote_state.kms_cryptokey.outputs.cryptokey_id
  ciphertext = var.github_token_ciphertext
}

resource "null_resource" "create_github_orgs_project" {
  triggers = {
    owner_id     = var.owner_id
    github_token = data.google_kms_secret.github_token.plaintext
    project_name = var.project_name
    filename     = "${path.module}/output.txt"
  }

  provisioner "local-exec" {
    command = <<EOT
      curl --request POST \
      --url https://api.github.com/graphql \
      --header 'Authorization: token ${self.triggers.github_token}' \
      --data '{"query":"mutation {createProjectV2(input: {ownerId: \"${self.triggers.owner_id}\" title: \"${self.triggers.project_name}\"}) {projectV2 {id}}}"}' | jq -r '.data.createProjectV2.projectV2.id' > ${self.triggers.filename}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      curl --request POST \
      --url https://api.github.com/graphql \
      --header 'Authorization: token ${self.triggers.github_token}' \
      --data '{"query":"mutation {deleteProjectV2(input: {clientMutationId: \"${self.triggers.owner_id}\" projectId: \"${trimsuffix("${file("${path.module}/output.txt")}", "\n")}\"}) {projectV2 {id}}}"}'
    EOT
  }
}
