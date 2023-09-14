output "connection_id" {
  value = aws_codestarconnections_connection.connection.id
  description = "The ID of the connection."
}

output "connection_arn" {
  value = aws_codestarconnections_connection.connection.arn
  description = "The ARN of the connection."
}

output "connection_connection_status" {
  value = aws_codestarconnections_connection.connection.connection_status
  description = "The current status of the connection."
}