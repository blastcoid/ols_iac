terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "orgs/teams/ols-dev-orgs-team"
  }
}

# module "gcp_team" {
#   source = "../../../modules/gcp/orgs/team"
# }

module "github_team" {
  source = "../../../modules/github/team"
  divisions = {
    technology = {
      privacy                   = "closed"
      description               = "Division for technology"
      create_default_maintainer = true
      department = {
        devops = {
          privacy                   = "closed"
          description               = "Department for devops"
          create_default_maintainer = true
        },
        backend = {
          privacy                   = "closed"
          description               = "Department for backend"
          create_default_maintainer = true
        },
        frontend = {
          privacy                   = "closed"
          description               = "Department for frontend"
          create_default_maintainer = true
        }
      }
    },
    business = {
      privacy                   = "closed"
      description               = "Division for business"
      create_default_maintainer = true
      department = {
        finance = {
          privacy                   = "closed"
          description               = "Department for finance"
          create_default_maintainer = true
        },
        accounting = {
          privacy                   = "closed"
          description               = "Department for accounting"
          create_default_maintainer = true
        },
        # marketting = {
        #   privacy                   = "closed"
        #   description               = "Department for marketting"
        #   create_default_maintainer = true
        # }
      }
    }
  }
}
