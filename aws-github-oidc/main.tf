terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create the IAM OIDC identity provider for GitHub.
# This establishes the trust relationship between your AWS account and GitHub.
# This only needs to be done once per AWS account.
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Corresponds to the "Get thumbprint" step in the AWS console.
  # This is the thumbprint for the GitHub OIDC provider's certificate.
  # It is static and can be retrieved from the AWS documentation or via their API.
  # This thumbprint is for the `token.actions.githubusercontent.com` certificate.
  # It's generally safe to hardcode this value as it changes infrequently.
  # You can verify it here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Build list of allowed repo subjects
locals {
  allowed_repos = concat([var.github_repo], var.additional_repos)
  allowed_subs  = [for r in local.allowed_repos : "repo:${var.github_org}/${r}:*"]
}

# Build the IAM policy document that specifies who can assume the role.
# It trusts the OIDC provider and restricts access to specific GitHub repositories.
data "aws_iam_policy_document" "github_actions_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # Condition to scope down access to specific GitHub repositories.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.allowed_subs
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create the IAM role that the GitHub Actions workflow will assume.
resource "aws_iam_role" "github_actions_role" {
  name               = var.role_name
  description        = "IAM role for GitHub Actions to deploy resources"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust_policy.json
}

# Attach the AdministratorAccess policy to the role.
# WARNING: This provides full access to your AWS account.
# For production environments, it is strongly recommended to create a custom,
# fine-grained policy with only the minimum permissions required.
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
