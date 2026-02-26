########################################################################################
# modules/aws/eks/terraform.tf
# Purpose:
# - Providers and versions needed by the EKS module
########################################################################################

########################################################################################
# Reference Documentation:
# https://registry.terraform.io/providers/hashicorp/aws/latest
########################################################################################

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47"
    }

  }
}
