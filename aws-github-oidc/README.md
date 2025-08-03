# README

Terraform manages the OIDC provider and the IAM role. The generated ARN for the role is
as follows, and must be used in your GitHub Actions workflow files:

github_actions_role_arn = "arn:aws:iam::629215267253:role/GitHubActionsRole"
