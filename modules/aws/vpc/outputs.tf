########################################################################################
# modules/aws/vpc/outputs.tf
# Purpose:
# - Export important values so OTHER stacks can reuse them.
#   Example: EKS stack needs vpc_id + private subnet ids.
########################################################################################

########################################################################################
# Reference Documentation:
# hhttps://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=outputs
########################################################################################

output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}
