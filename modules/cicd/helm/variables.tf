# GCP Settings
variable "region" {
  type        = string
  description = "AWS or GCP region"
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for resources."
  default     = {}
}

variable "cloud_provider" {
  type        = string
  description = "cloud provider"
  default     = "gcp"
}

variable "project_id" {
  type        = string
  description = "GCP project id"
  default     = null
}

# GCP arguments
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

# AWS arguments
variable "eks_oidc_url" {
  type        = string
  description = "EKS OIDC url"
  default     = null
}

variable "eks_oidc_arn" {
  type        = string
  description = "EKS OIDC arn"
  default     = null
}

variable "iam_policy" {
  type        = string
  description = "IAM policy"
  default     = null
}

# helm arguments

variable "override_name" {
  type        = string
  description = "override helm name"
  default     = null
}

variable "repository" {
  type        = string
  description = "helm repository"
}

variable "repository_username" {
  type        = string
  description = "helm repository username"
  default     = null
}

variable "repository_password" {
  type        = string
  description = "helm repository password"
  default     = null
}

variable "chart" {
  type        = string
  description = "helm chart"
}

variable "helm_version" {
  type        = string
  description = "helm chart version"
  default     = null
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

# variable "after_helm_manifest" {
#   type        = string
#   description = "after helm manifest"
#   default     = null
# }

variable "k8s_manifests" {
  type        = list(string)
  description = "Kubernetes manifest after helm release"
  default     = []
}

# variable "after_crd_installed" {
#   type        = string
#   description = "after crd installed"
#   default     = null
# }

variable "kubectl_manifests" {
  type        = list(string)
  description = "Kubectl manifest after helm release"
  default     = []
}

variable "extra_vars" {
  type        = map(any)
  description = "helm values extra vars"
  default     = {}
  sensitive   = true
}
