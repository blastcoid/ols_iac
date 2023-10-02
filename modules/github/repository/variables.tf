# Github Settings

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

# Github repository arguments
variable "homepage_url" {
  type        = string
  description = "URL of a page describing the project."
  default     = false
}

#deprecated
variable "is_private" {
  type        = bool
  description = "Set to true to create a private repository."
  default     = false
}

variable "visibility" {
  type        = string
  description = "The visibility of the repository. Can be public or private."
}

variable "has_issues" {
  type        = bool
  description = "Set to true to enable the GitHub Issues features on the repository."
  default     = false
}

variable "has_discussions" {
  type        = bool
  description = "Set to true to enable the GitHub Discussions features on the repository."
  default     = false
}

variable "has_projects" {
  type        = bool
  description = "Set to true to enable the GitHub Projects features on the repository."
  default     = false
}

variable "has_wiki" {
  type        = bool
  description = "Set to true to enable the GitHub Wiki features on the repository."
  default     = false
}

variable "is_template" {
  type        = bool
  description = "Set to true to enable the GitHub Template features on the repository."
  default     = false
}

variable "delete_branch_on_merge" {
  type        = bool
  description = "Automatically delete head branches when pull requests are merged."
  default     = false
}

## Deprecated
variable "has_downloads" {
  type        = bool
  description = "Set to true to enable the GitHub Downloads features on the repository."
  default     = false
}

variable "auto_init" {
  type        = bool
  description = "Set to true to produce an initial commit in the repository."
  default     = false
}

variable "gitignore_template" {
  type        = string
  description = "Use the name of the template without the extension. For example, 'Haskell'."
  default     = null
}

variable "license_template" {
  type        = string
  description = "Use the name of the license without the extension. For example, 'mit' or 'mpl-2.0'."
  default     = "apache-2.0"
}

# Deprecated
variable "default_branch" {
  type        = string
  description = "The name of the default branch of the repository. If not set, GitHub will set it to master."
  default     = "main"
}

variable "archived" {
  type        = bool
  description = "Set to true to archive the repository."
  default     = false
}

variable "archive_on_destroy" {
  type        = bool
  description = "Set to true to archive the repository when the resource is destroyed."
  default     = false
}

variable "pages" {
  type = object({
    source = optional(object({
      branch = optional(string)
      path   = optional(string)
    }))
    build_type = optional(string)
    cname      = optional(string)
  })
  description = "Configuration for GitHub Pages."
  default     = null
}

variable "security_and_analysis" {
  type = object({
    advanced_security = object({
      status = optional(string)
    })
    secret_scanning = object({
      status = optional(string)
    })
    secret_scanning_push_protection = object({
      status = optional(string)
    })
  })
  description = "Configuration for GitHub Security and Analysis."
  default     = null
}

variable "topics" {
  type        = list(string)
  description = "A list of topics to apply to the repository."
  default     = []
}

variable "template" {
  type = object({
    owner                = optional(string)
    repository           = optional(string)
    include_all_branches = optional(bool)
  })
  description = "Template to be used to create the repository."
  default     = null
}

variable "vulnerability_alerts" {
  type        = bool
  description = "Set to true to enable vulnerability alerts for the repository."
  default     = false
}

variable "ignore_vulnerability_alerts_during_read" {
  type        = bool
  description = "Set to true to ignore vulnerability alerts for the repository."
  default     = false
}

variable "allow_update_branch" {
  type        = bool
  description = "Set to true to allow updates to the default branch of the repository."
  default     = false
}

# Github repository autolink arguments
variable "key_prefix" {
  type        = string
  description = "This prefix appended by a number will generate a link any time it is found in an issue, pull request, or commit."
  default     = null
}

variable "target_url_template" {
  type        = string
  description = "The template of the target URL used for the links; must be a valid URL and contain <num> for the reference number"
  default     = null
}

variable "is_alphanumeric" {
  type        = bool
  description = "Whether this autolink reference matches alphanumeric characters. If false, this autolink reference only matches numeric characters. Default is true."
  default     = false
}

# Github branch protection arguments
variable "list_of_protect_branch" {
  type        = list(string)
  description = "List of branch to be protected"
  default     = []
}

variable "enforce_admins" {
  type        = bool
  description = "Enforce all configured restrictions for administrators."
  default     = false
}

variable "required_status_checks" {
  type = object({
    strict = optional(bool)
    checks = optional(list(string))
  })
  description = "Enforce required status checks before merging."
  default     = null
}

variable "required_pull_request_reviews" {
  type = object({
    dismiss_stale_reviews           = optional(bool)
    dismissal_users                 = optional(list(string))
    dismissal_teams                 = optional(list(string))
    require_code_owner_reviews      = optional(bool)
    required_approving_review_count = optional(number)
    bypass_pull_request_allowances = optional(object({
      users = optional(list(string))
      teams = optional(list(string))
      apps  = optional(list(string))
    }))
  })
  description = "Require at least one approving review on a pull request, before merging."
  default     = null
}

variable "restrictions" {
  type = object({
    users = optional(list(string))
    teams = optional(list(string))
    apps  = optional(list(string))
  })
  description = "Restrict who can push to this branch."
  default     = null
}

# Github webhooks arguments
variable "webhooks" {
  type = map(object({
    configuration = object({
      url          = string
      content_type = string
      insecure_ssl = bool
      secret       = string
    })
    active = bool
    events = list(string)
  }))
  description = "Map of webhooks to be added to the repository"
  default     = {}
}

variable "teams_permission" {
  type        = map(string)
  description = "List of teams permission to be added to the repository"
}

# Github deploy key arguments

variable "ssh_key" {
  type        = string
  description = "The SSH key to add to the repository."
  default     = null
}

variable "public_key" {
  type        = string
  description = "The public key to add to the repository."
  default     = null
}

variable "is_deploy_key_read_only" {
  type        = bool
  description = "Set to true to create a read-only deploy key."
  default     = true
}

# Kubernetes arguments
variable "argocd_namespace" {
  type        = string
  description = "ArgoCD namespace"
  default     = null
}

variable "github_action_secrets" {
  description = "List of secrets to be added to the repository github actions"
  default = {}
}
