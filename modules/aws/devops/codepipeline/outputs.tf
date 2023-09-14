# Codepipeline role outputs
output "codepipeline_role_arn" {
  value       = aws_iam_role.role.arn
  description = "The Amazon Resource Name (ARN) specifying the role."
}

# Codepipeline outputs

output "codepipeline_id" {
  value       = aws_codepipeline.codepipeline.id
  description = "The codepipeline ID."
}

output "codepipeline_arn" {
  value       = aws_codepipeline.codepipeline.arn
  description = "The codepipeline ARN."
}

output "codepipeline_tags_all" {
  value       = aws_codepipeline.codepipeline.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}
