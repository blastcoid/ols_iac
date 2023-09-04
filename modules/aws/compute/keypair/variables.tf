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

# Key Pair arguments
variable "algorithm" {
  type        = string
  description = "The algorithm to use for the key pair. Valid values are RSA and ECDSA."
  default     = "RSA"
}

variable "rsa_bits" {
  type        = number
  description = "The number of bits to use for the key pair created."
  default     = 2048
}

variable "ssm_type" {
  type        = string
  description = "The type of the parameter. Valid values are String, StringList and SecureString."
  default     = "SecureString"
}