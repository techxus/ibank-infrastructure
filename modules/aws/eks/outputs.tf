############################################
# modules/aws/eks/outputs.tf
#
# PURPOSE:
# Expose values other modules need, especially
# the OIDC provider details for IRSA roles.
#
# STUDENT NOTE:
# oidc_provider_arn comes from our own
# aws_iam_openid_connect_provider resource —
# NOT from module.eks — because we disabled
# enable_irsa on the module and manage the
# OIDC provider ourselves. Always reference
# the resource you actually control.
############################################

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider. Used in IRSA trust policies as the Federated principal."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_oidc_issuer_url" {
  description = "Full OIDC issuer URL with https://. Used in IRSA trust policy condition keys."
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks.cluster_security_group_id
}