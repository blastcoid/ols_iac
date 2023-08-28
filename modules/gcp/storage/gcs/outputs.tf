# cloud storage bucket output

output "bucket_name" {
  value = google_storage_bucket.bucket.name
  description = "The name of the bucket."
}

output "bucket_url" {
  value = google_storage_bucket.bucket.url
  description = "The URI of the created resource."
}

output "bucket_self_link" {
  value = google_storage_bucket.bucket.self_link
  description = "The link to the bucket."
}
