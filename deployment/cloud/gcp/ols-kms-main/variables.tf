# Naming Standard
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
  default     = "security"
}

variable "feature" {
  type        = list(string)
  description = "Feature names"
  default     = ["kms-sa", "kms-keyring", "kms-cryptokey"]
}
