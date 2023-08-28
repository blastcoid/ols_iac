# create google secret manager outputs

output "secret_id" {
  value = google_secret_manager_secret.secret.id
}

output "secret_version_id" {
  value = google_secret_manager_secret_version.secret_version.id
}

output "secret_version" {
  value = google_secret_manager_secret_version.secret_version.id
}

# output "secret_version_data" {
#   value = google_secret_manager_secret_version.secret_version.secret_data
#   sensitive = true
# }