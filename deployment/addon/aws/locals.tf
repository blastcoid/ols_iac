locals {
  name   = basename(path.cwd)
  region = "us-west-1"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints-addons"
  }
}