# Workload identity output
output "service_account_email" {
  value = google_service_account.gsa.email
  description = "Google service account email"
}