# GCP Settings
variable "region" {
  type        = string
  description = "GCP region"
}
variable "env" {
  type        = string
  description = "stage environment where the infrastructure will be deployed"
}

# Google Secret Manager arguments

variable "secret_name_prefix" {
  type        = string
  description = "The name of the secret manager"
}

variable "secret_data" {
  description = "The secrets to be stored in the secret manager"
}
