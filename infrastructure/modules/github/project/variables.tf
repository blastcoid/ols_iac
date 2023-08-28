# GCP Settings
variable "github_token_ciphertext" {
  type = string
  description = "Github token ciphertext"
}

# github project arguments

variable "project_name" {
  type = string
  description = "Github project name"
}

variable "owner_id" {
  type = string
  description = "Github organization node id"
}