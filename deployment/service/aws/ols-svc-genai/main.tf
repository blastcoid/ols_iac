module "ssm_params" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.1.0"

  for_each = local.parameters

  name            = "${local.ssm_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}"
  value           = try(each.value.value, null)
  values          = try(each.value.values, [])
  type            = try(each.value.type, null)
  secure_type     = try(each.value.secure_type, null)
  description     = try(each.value.description, "Config parameter for ${local.ssm_naming_standard}/${split("_", each.key)[0]}/${upper(each.key)}")
  tier            = try(each.value.tier, null)
  key_id          = try(each.value.key_id, null)
  allowed_pattern = try(each.value.allowed_pattern, null)
  data_type       = try(each.value.data_type, null)
  tags            = local.svc_standard
}

module "github_repository" {
  source                 = "../../../../modules/github/repository"
  standard               = local.svc_standard
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
  webhooks = {
    "codepipeline" = {
      active = true
      events = ["push"]
      configuration = {
        url          = module.codepipeline.codepipeline_webhook_url
        content_type = "json"
        insecure_ssl = false
        secret       = module.ssm_params["github_secret"].secure_value
      }
      insecure_ssl = false
    }
  }
}

module "irsa_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version     = "~> 5.30.0"
  name        = local.svc_naming_standard
  path        = "/"
  description = "Policy for ${local.svc_naming_standard}"

  policy = data.aws_iam_policy_document.irsa_policy.json

  tags = {
    PolicyDescription = "Policy created using example from data source"
  }
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30.0"

  role_name = local.svc_naming_standard

  role_policy_arns = {
    policy = module.irsa_policy.arn
  }

  oidc_providers = {
    app = {
      provider_arn               = data.terraform_remote_state.all.outputs.main_eks_oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${local.svc_naming_standard}"]
    }
  }
}

module "bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = "~> 3.15.1"
  bucket                   = local.svc_naming_standard
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  attach_policy            = true
  policy                   = data.aws_iam_policy_document.custom_bucket_policy.json
  expected_bucket_owner    = data.aws_caller_identity.current.account_id
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = data.terraform_remote_state.all.outputs.main_key_arn
      }
    }
  }
  versioning = {
    enabled = true
  }

  tags = local.svc_standard
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6.0"

  count                             = length(local.namespaces)
  repository_name                   = "${local.namespaces[count.index]}/${local.svc_naming_standard}"
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/iac"]
  repository_image_tag_mutability   = "MUTABLE"
  repository_encryption_type        = "KMS"
  repository_kms_key                = data.terraform_remote_state.all.outputs.main_key_arn
  registry_scan_type                = "BASIC"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["alpha", "beta", "v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
      # {
      #   rulePriority = 1
      #   description  = "Remove image more than 10"
      #   selection = {
      #     tagStatus   = "any"
      #     countType   = "imageCountMoreThan"
      #     countNumber = 10
      #   }
      #   action = {
      #     type = "expire"
      #   }
      # }
    ]
  })

  tags = local.svc_standard
}

module "codestar_connection" {
  source        = "../../../../modules/aws/devops/codestar"
  region        = var.region
  standard      = local.svc_standard
  name          = local.svc_naming_standard
  provider_type = "GitHub"
}

module "codebuild" {
  source           = "../../../../modules/aws/devops/codebuild"
  region           = var.region
  standard         = local.svc_standard
  name             = local.svc_naming_standard
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
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type            = "ARM_CONTAINER"
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
        value = module.github_repository.name[0]
      },
      {
        name  = "ECR_DOCKER_REPOSITORY_URI"
        value = module.ecr[0].repository_url
      },
      {
        name  = "ECR_HELM_REPOSITORY_URI"
        value = "${split("/", module.ecr[1].repository_url)[0]}/${split("/", module.ecr[1].repository_url)[1]}/"
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
    # location = "${module.bucket.bucket_id}/codebuild/cache"
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
    subnet_ids = data.terraform_remote_state.all.outputs.main_node_subnet_ids
    vpc_id     = data.terraform_remote_state.all.outputs.main_vpc_id
  }
}

module "codepipeline" {
  source              = "../../../../modules/aws/devops/codepipeline"
  region              = var.region
  standard            = local.svc_standard
  name                = local.svc_naming_standard
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
    location = module.bucket.s3_bucket_id
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
  github_secret          = module.ssm_params["github_secret"].secure_value
}

module "argocd_app" {
  source         = "../../../../modules/cicd/helm"
  region         = var.region
  standard       = local.svc_standard
  cloud_provider = "aws"
  repository     = "https://argoproj.github.io/argo-helm"
  chart          = "argocd-apps"
  values         = ["${file("helm/${local.svc_standard.Feature}.yaml")}"]
  namespace      = "cd"
  project_id     = "${var.unit}-platform-${var.env}"
  dns_name       = "${var.env}.ols.blast.co.id" #trimsuffix(data.terraform_remote_state.dns_blast.outputs.dns_name, ".")
  extra_vars = {
    argocd_namespace      = "cd"
    source_repoURL        = "https://github.com/blastcoid/ols_helm"
    source_targetRevision = "HEAD"
    source_path = var.env == "dev" || var.env == "mstr" ? "charts/incubator/${local.svc_name}" : (
      var.env == "stg" ? "charts/test/${local.svc_name}" : "charts/stable/${local.svc_name}"
    )
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = var.env
    avp_type                               = "awssecretsmanager"
    region                                 = var.region
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}
