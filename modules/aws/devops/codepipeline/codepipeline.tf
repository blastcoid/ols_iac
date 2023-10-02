resource "aws_codepipeline" "codepipeline" {
  name     = var.name
  role_arn = aws_iam_role.role.arn

  dynamic "artifact_store" {
    for_each = [var.artifact_store]
    content {
      location = artifact_store.value.location
      type     = artifact_store.value.type
      dynamic "encryption_key" {
        for_each = artifact_store.value.encryption_key != null ? [artifact_store.value.encryption_key] : []
        content {
          id   = encryption_key.value.id
          type = encryption_key.value.type
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name
      dynamic "action" {
        for_each = [stage.value.action]
        content {
          category         = action.value.category
          owner            = action.value.owner
          name             = action.value.name
          provider         = action.value.provider
          version          = action.value.version
          input_artifacts  = action.value.input_artifacts
          output_artifacts = action.value.output_artifacts
          configuration    = action.value.configuration
          role_arn         = action.value.role_arn
          run_order        = action.value.run_order
          region           = action.value.region
          namespace        = action.value.namespace
        }
      }
    }
  }
  tags = var.standard
}
