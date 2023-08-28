resource "github_membership" "membership" {
  username = var.username
  role     = var.organization_role
}

resource "github_team_members" "team_members" {
  count   = length(var.teams)
  team_id = var.teams[count.index].slug
  members {
    username = var.username
    role     = var.teams[count.index].role
  }
}

resource "github_repository_collaborator" "a_repo_collaborator" {
  for_each   = var.repositories_collaborator != {} ? var.repositories_collaborator : {}
  repository = each.key
  username   = var.username
  permission = each.value
}
