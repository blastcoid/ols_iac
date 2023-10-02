resource "aws_codestarconnections_connection" "connection" {
  name          = var.name
  provider_type = var.provider_type
  tags          = var.standard
}
