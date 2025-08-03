variable "github_org" {
  description = "The GitHub organization or username."
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name."
  type        = string
}

variable "role_name" {
  description = "The name of the IAM role to create."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}
