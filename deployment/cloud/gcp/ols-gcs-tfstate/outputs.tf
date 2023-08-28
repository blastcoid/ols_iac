output "bucket_name" {
  value       = module.gcs_tfstate.bucket_name
  description = "The name of the created Google Cloud Storage bucket."
}

output "bucket_url" {
  value       = module.gcs_tfstate.bucket_url
  description = "The URL of the created Google Cloud Storage bucket."
}

output "bucket_self_link" {
  value       = module.gcs_tfstate.bucket_self_link
  description = "The self link of the created Google Cloud Storage bucket, useful for referencing the bucket in other resources within the same project."
}
