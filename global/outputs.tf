############################################
# outputs.tf
############################################

# IAM outputs
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions ECR push"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

# ECR outputs
output "repository_urls" {
  description = "Map of service name to ECR repository URL"
  value = {
    for name, repo in aws_ecr_repository.services :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of service name to ECR repository ARN"
  value = {
    for name, repo in aws_ecr_repository.services :
    name => repo.arn
  }
}
