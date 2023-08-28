// Google Cloud Storage Bucket Configuration
resource "google_storage_bucket" "bucket" {
  // Construct bucket name using provided variables
  name          = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  
  // Set the geographical region for the bucket
  location      = "${var.region}"
  
  // Determine if all objects should be forcefully deleted from the bucket when destroying the bucket
  force_destroy = var.force_destroy

  // Set the public access prevention level for the bucket
  public_access_prevention = var.public_access_prevention
}
