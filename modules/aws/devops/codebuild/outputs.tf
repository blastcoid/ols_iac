# IAM role outputs
output "codebuild_role_arn" {
  value       = aws_iam_role.role.arn
  description = "The Amazon Resource Name (ARN) specifying the role."
}

# Codebuild outputs
output "codebuild_arn" {
  value       = aws_codebuild_project.project.arn
  description = "ARN of the CodeBuild project."
}

output "codebuild_id" {
  value       = aws_codebuild_project.project.id
  description = "Name (if imported via name) or ARN (if created via Terraform or imported via ARN) of the CodeBuild project."
}

output "codebuild_name" {
  value       = aws_codebuild_project.project.name
  description = "Name of the CodeBuild project."
}

output "codebuild_public_project_alias" {
  value       = aws_codebuild_project.project.public_project_alias
  description = "The project identifier used with the public build APIs."
}

output "codebuild_tags_all" {
  value       = aws_codebuild_project.project.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}
