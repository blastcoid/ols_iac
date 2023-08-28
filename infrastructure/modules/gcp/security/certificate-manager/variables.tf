#Naming Standard
variable "region" {
  type        = string
  description = "GCP region"
}

variable "unit" {
  type        = string
  description = "business unit code"
}

variable "env" {
  type        = string
  description = "stage environment where the infrastructure will be deployed"
}

variable "code" {
  type        = string
  description = "service domain code to use"
}

variable "feature" {
  type        = string
  description = "the name of AWS services feature"
}

# gcm arguments

variable "gcm_name" {
  type        = string
  description = "the name of GCM"
}

variable "gcm_domains" {
  type        = list(string)
  description = "the list of domains to be used in GCM"
}