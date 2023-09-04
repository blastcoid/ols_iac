# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

# service account arguments
variable "service_account_name" {
  type        = string
  description = "The name of the google service account to create."
}

variable "google_service_account_role" {
  type        = string
  description = "The role to assign to the service account."
}

