#Naming Standard
variable "region" {
  type        = string
  description = "The geographical region of the bucket. See the official docs for valid values: https://cloud.google.com/storage/docs/locations"
}

variable "unit" {
  type        = string
  description = "Business unit code."
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

variable "code" {
  type        = string
  description = "Service domain code to use."
}

variable "feature" {
  type        = list(string)
  description = "The features feature."
}

# Google Cloud Storage Bucket Configuration
variable "force_destroy" {
  type        = bool
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."
}

variable "public_access_prevention" {
  type        = string
  description = "Prevents public access to a bucket. Acceptable values are 'inherited' or 'enforced'."
}
