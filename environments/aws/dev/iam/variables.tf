variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}


variable "vault_kms_key_arn" {
  description = "KMS key ARN for Vault unseal policy"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for Pod Identity associations"
  type        = string
}