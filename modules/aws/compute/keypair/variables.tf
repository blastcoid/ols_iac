# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
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