#Naming Standard
variable "region" {
  type        = string
  description = "AWS region"
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
  type        = list(string)
  description = "the name of AWS services feature"
}

# KMS arguments
variable "kms_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource."
}

variable "kms_enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled."
}

variable "kms_is_enabled" {
  type        = bool
  description = "Specifies whether the key is enabled."
}

variable "kms_key_usage" {
  type        = string
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "kms_policy" {
  type        = string
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform."
}

variable "kms_customer_master_key_spec" {
  type        = string
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
}