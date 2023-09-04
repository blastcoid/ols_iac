# create google secret manager outputs

output "secret_id" {
  value = { for k, v in google_secret_manager_secret.secret : k => v.id }
}

output "secret_version_id" {
  value = { for k, v in google_secret_manager_secret_version.secret_version : k => v.id }
}

output "secret_version_data" {
  value = { for k, v in google_secret_manager_secret_version.secret_version : k => v.secret_data }
  sensitive = true
}