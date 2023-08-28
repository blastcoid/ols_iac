# github organization project outputs
# no longer support
# output "project_url" {
#   value = github_organization_project.project.url
#   description = "Github organization project url"
# }

data "local_file" "project_id" {
  # Referring to null_resource.test here ensures that the provisioner
  # will complete before Terraform attempts to read this file.
  filename = null_resource.create_github_orgs_project.triggers.filename
}

output "project_id" {
  value = trimsuffix(data.local_file.project_id.content, "\n")
}