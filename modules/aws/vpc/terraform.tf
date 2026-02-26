########################################################################################
# modules/aws/vpc/terraform.tf
# Purpose:
# - Declare which Terraform version we support
# - Declare providers we use (aws)
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
