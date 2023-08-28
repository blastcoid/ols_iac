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

# cloud dns arguments
variable "zone_name" {
  type        = string
  description = "the zone name to use"
}

variable "dns_name" {
  type        = string
  description = "the dns name to use"
}

variable "zone_description" {
  type        = string
  description = "the zone description to use"
}

variable "force_destroy" {
  type        = bool
  description = "the force destroy to use"
}

variable "visibility" {
  type        = string
  description = "the visibility to use"
  default     = "public"
}