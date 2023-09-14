# ECR outputs

output "repository_id" {
  description = "The ID of the repository."
  value       = aws_ecr_repository.repository.*.id
}

output "repository_name" {
  description = "The name of the repository."
  value       = aws_ecr_repository.repository.*.name
}

output "repository_arn" {
  description = "The ARN of the repository."
  value       = aws_ecr_repository.repository.*.arn
}

output "repository_url" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.repository.*.repository_url
}