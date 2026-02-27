output "runner_role_arn" {
  description = "IAM role ARN for GitHub Actions runner"
  value       = aws_iam_role.runner.arn
}

output "runner_security_group_id" {
  description = "Security group ID for GitHub Actions runner"
  value       = aws_security_group.runner.id
}

output "autoscaling_group_name" {
  description = "Auto scaling group name for GitHub Actions runner"
  value       = aws_autoscaling_group.runner.name
}