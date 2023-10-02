# AWS Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

variable "name" {
  type        = string
  description = "The name of the build project."
}

# Codestar arguments
variable "provider_type" {
  type        = string
  description = "The type of provider to connect to the repository. Valid values are Bitbucket, GitHub, GitHubEnterpriseServer, and GitLab."
}
