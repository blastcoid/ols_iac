terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "orgs/member/ols-dev-orgs-member-idanfreak"
  }
}

# invite github
module "github_membership" {
  source            = "../../../../modules/github/membership"
  username          = "idanfreak"
  organization_role = "member"
  teams = [
    {
      slug = "technology"
      role = "member"
    },
    {
      slug = "devops"
      role = "maintainer"
    }
  ]
  repositories_collaborator = {
    "ols_iac" = "maintain"
  }
}
