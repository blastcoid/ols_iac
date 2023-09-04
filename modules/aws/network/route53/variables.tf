# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "us-west-2"
}

variable "unit" {
  type        = string
  description = "Business unit code."
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

variable "code" {
  type        = string
  description = "Service domain code."
}

variable "feature" {
  type        = list(string)
  description = "Service feature."
}

# Route53 arguments
variable "route53_zone_name" {
  type        = string
  description = "The name of the zone."
}

variable "route53_force_destroy" {
  type        = bool
  description = "Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone."
  default     = false
}
