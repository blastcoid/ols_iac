output "firestore_id" {
  value = google_firestore_database.database.id
  description = "The ID of the Firestore database."
}