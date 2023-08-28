# Create organization division
resource "github_team" "division" {
  for_each                  = var.divisions
  name                      = each.key
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = each.value.create_default_maintainer
}

resource "github_team_settings" "code_review_settings" {
  for_each = var.divisions
  team_id  = each.key
  review_request_delegation {
    algorithm    = "ROUND_ROBIN"
    member_count = 1
    notify       = true
  }
}

locals {
  divisions = { for unit in flatten([
    for division, divisions in var.divisions : [
      for department, departments in divisions.department : {
        division                  = division
        department                = department
        description               = departments.description
        privacy                   = departments.privacy
        create_default_maintainer = departments.create_default_maintainer
      }
    ]
    ]) : "${unit.division}/${unit.department}" => unit
  }
}

# Create organization departments
resource "github_team" "department" {
  for_each                  = local.divisions
  name                      = each.value.department
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = each.value.create_default_maintainer
  parent_team_id            = github_team.division[each.value.division].id
}
