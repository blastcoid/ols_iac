# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project id where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for resources."
}

# Firestore Index arguments

variable "database_name" {
  type        = string
  description = "The name of the Firestore database."
}

variable "collection_name" {
  type        = string
  description = "The name of the Firestore collection."
}

variable "fields" {
  type        = list(map(string))
  description = "The fields to be indexed."
}
