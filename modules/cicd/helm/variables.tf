# GCP Settings
variable "region" {
  type        = string
  description = "GCP region"
}

variable "standard" {
  type = map(string)
  description = "The standard naming convention for resources."
}

variable "project_id" {
  type        = string
  description = "GCP project id"
}

# service account arguments
variable "create_service_account" {
  type        = bool
  description = "create google service account"
  default     = false
}

variable "use_workload_identity" {
  type        = bool
  description = "use google workload identity"
  default     = false
}

variable "google_service_account_role" {
  type        = list(string)
  description = "GCP service account role"
  default     = []
}

# helm arguments

variable "repository" {
  type        = string
  description = "helm repository"
}

variable "chart" {
  type        = string
  description = "helm chart"
}

variable "values" {
  type        = list(string)
  description = "helm values"
  default     = []
}

variable "namespace" {
  type        = string
  description = "helm namespace"
  default     = null
}

variable "create_namespace" {
  type        = bool
  description = "create namespace"
  default     = false
}

variable "dns_name" {
  type        = string
  description = "dns name"
  default     = null
}

variable "create_managed_certificate" {
  type        = bool
  description = "create managed certificate"
  default     = false
}

variable "helm_sets" {
  type        = list(object({ name : string, value : any }))
  description = "list of helm set"
  default     = []
}

variable "helm_sets_sensitive" {
  type        = list(object({ name : string, value : any }))
  description = "list of helm set sensitive"
  default     = []
}

variable "helm_sets_list" {
  type        = list(object({ name : string, value : list(string) }))
  description = "list of helm set list"
  default     = []
}

variable "after_helm_manifest" {
  type        = string
  description = "after helm manifest"
  default     = null
}

variable "after_crd_installed" {
  type        = string
  description = "after crd installed"
  default     = null
}

variable "extra_vars" {
  type        = map(any)
  description = "helm values extra vars"
  default     = {}
  sensitive   = true
}
