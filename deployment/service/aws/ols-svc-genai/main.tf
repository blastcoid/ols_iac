# Append SSH key to list of secrets
locals {
  # ssm_secrets = merge(
  #   local.secret_map,
  #   { "GIT_SSH_PRIVATE_KEY" = data.aws_ssm_parameter.ssh_key.value }
  # )

  # Decrypt secrets ciphertext to plaintext and convert data aws kms secrets to map
  ssm_secrets = { for k, v in data.aws_kms_secrets.secrets : k => v.plaintext[k] }
  github_secrets = {
    "GIT_SSH_PRIVATE_KEY" = data.aws_ssm_parameter.ssh_key.value
  }
}

module "ssm_params" {
  source = "../../../../modules/aws/devops/ssm"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "ops"
    feature = "ssm"
    sub     = "svc"
    name    = "genai"
  }
  tier    = "Standard"
  configs = var.configs
  secrets = local.ssm_secrets
}

module "github_repository" {
  source = "../../../../modules/github/repository"
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "svc"
    feature = "genai"
  }
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = false
  auto_init              = true
  gitignore_template     = "Python"
  license_template       = "apache-2.0"
  security_and_analysis = {
    advanced_security = {
      status = "enabled"
    }
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }
  topics               = ["python", "openai", "fastapi", "service", "docker", "argocd", "aws", "gcp", "kubernetes"]
  vulnerability_alerts = true
  teams_permission = {
    technology = "pull"
    devops     = "triage"
  }
  github_action_secrets = local.github_secrets
}

module "s3_bucket" {
  source = "../../../../modules/aws/storage/s3"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "stor"
    feature = "s3"
    sub     = "svc"
    name    = "genai"
  }
  account_id              = data.aws_caller_identity.current.account_id
  force_destroy           = true
  object_lock_enabled     = false
  bucket_acl              = "private"
  bucket_object_ownership = "BucketOwnerPreferred"
  bucket_policy           = data.aws_iam_policy_document.bucket_policy.json
}

module "ecr_repository" {
  source = "../../../../modules/aws/container/ecr"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "con"
    feature = "ecr"
    sub     = "svc"
    name    = "genai"
  }
  namespaces           = ["images", "charts"]
  image_tag_mutability = "MUTABLE"
  encryption_configuration = {
    encryption_type = "KMS"
    kms_key         = data.terraform_remote_state.all.outputs.main_key_arn
  }
  scan_on_push = true
  force_delete = true
  ecr_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove image more than 10"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
  scan_type = "BASIC"
}

module "codestar_connection" {
  source = "../../../../modules/aws/devops/codestar"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "ops"
    feature = "cs"
    sub     = "svc"
    name    = "genai"
  }
  provider_type = "GitHub"
}

module "codebuild" {
  source = "../../../../modules/aws/devops/codebuild"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "ops"
    feature = "cb"
    sub     = "svc"
    name    = "genai"
  }
  codebuild_policy = data.aws_iam_policy_document.codebuild_policy.json
  kms_grant_operations = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "GenerateDataKeyPair",
    "GenerateDataKeyPairWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
    "DescribeKey"
  ]
  encryption_key = data.terraform_remote_state.all.outputs.main_key_arn
  artifacts = {
    type = "CODEPIPELINE"
  }

  environment = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variables = [
      {
        name  = "STAGE"
        value = "BUILD"
      },
      {
        name  = "AWS_REGION"
        value = var.region
      },
      {
        name  = "SERVICE_NAME"
        value = replace(module.github_repository.name[0], "_", "-")
      },
      {
        name  = "ECR_DOCKER_REPOSITORY_URI"
        value = module.ecr_repository.repository_url[0]
      },
      {
        name  = "ECR_HELM_REPOSITORY_URI"
        value = "${split("/", module.ecr_repository.repository_url[1])[0]}/${split("/", module.ecr_repository.repository_url[1])[1]}/"
      },
      {
        # Get value from SSM parameter store
        name  = "HELM_SSH_PRIVATE_KEY"
        value = "/${var.unit}/${var.env}/ops/ssm/iac/ssh/SSH_KEY_MAIN"
        type  = "PARAMETER_STORE"
      },
      {
        name  = "GITHUB_HELM_SSH_CLONE_URL"
        value = "git@github.com:blastcoid/ols_helm.git"
      },
      {
        name  = "GITHUB_EMAIL"
        value = "imam@blast.co.id"
      },
      {
        name  = "GITHUB_USERNAME"
        value = "greyhats13"
      }
    ]
  }
  cache = {
    # type = "S3"
    # location = "${module.s3_bucket.bucket_id}/codebuild/cache"
    type = "LOCAL"
    modes = [
      "LOCAL_CUSTOM_CACHE",
      "LOCAL_DOCKER_LAYER_CACHE",
      "LOCAL_SOURCE_CACHE"
    ]
  }
  sources = {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  vpc_config = {
    subnet_ids = data.terraform_remote_state.all.outputs.main_node_subnet_id
    vpc_id     = data.terraform_remote_state.all.outputs.main_vpc_id
  }
}

module "codepipeline" {
  source = "../../../../modules/aws/devops/codepipeline"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "ops"
    feature = "cp"
    sub     = "svc"
    name    = "genai"
  }
  codepipeline_policy = data.aws_iam_policy_document.codepipeline_policy.json
  kms_grant_operations = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "GenerateDataKeyPair",
    "GenerateDataKeyPairWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
    "DescribeKey"
  ]
  artifact_store = {
    location = module.s3_bucket.bucket_id
    type     = "S3"
    encryption_key = {
      id   = data.terraform_remote_state.all.outputs.main_key_arn
      type = "KMS"
    }
  }

  stages = [
    {
      name = "Source"
      action = {
        name     = "Source"
        category = "Source"
        owner    = "AWS"
        provider = "CodeStarSourceConnection"
        version  = "1"
        configuration = {
          ConnectionArn    = module.codestar_connection.connection_arn
          FullRepositoryId = module.github_repository.full_name[0]
          BranchName       = "dev"
        }
        output_artifacts = ["Source"]
      }
    },
    {
      name = "Build"
      action = {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["Source"]
        output_artifacts = ["BuildArtifact"]
        version          = "1"

        configuration = {
          ProjectName = module.codebuild.codebuild_name
        }
      }
    }
  ]
  webhook_authentication = "GITHUB_HMAC"
  webhook_target_action  = "Source"
  github_repository_name = module.github_repository.name[0]
}
