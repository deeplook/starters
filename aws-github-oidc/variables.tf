variable "github_org" {
  description = "The GitHub organization or username."
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name."
  type        = string
}

variable "additional_repos" {
  description = "Additional GitHub repositories (names only) within github_org to trust."
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "The name of the IAM role to create."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}
