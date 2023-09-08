resource "google_firestore_index" "index" {
  project    = var.project_id
  database   = var.database_name
  collection = var.collection_name

  dynamic "fields" {
    for_each = var.fields
    content {
      field_path = fields.value["field_path"]
      order      = fields.value["order"]
    }  
  }
}