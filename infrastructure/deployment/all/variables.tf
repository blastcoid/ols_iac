variable "unit" {
  description = "Business unit"
  type        = string
  default     = "ols"
}

variable "env" {
  description = "Stage environment defined at terraform.tfvars"
  type        = string
}