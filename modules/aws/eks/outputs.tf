############################################
# modules/aws/eks/outputs.tf
############################################

output "oidc_provider" {
  description = "OIDC issuer host/path WITHOUT https:// (for IRSA conditions)."
  value       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}