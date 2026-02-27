############################################
# environments/aws/dev/vpc/main.tf
# Purpose:
# - Create VPC for dev environment
# - EKS will read outputs from this workspace
############################################
module "vpc" {
  source = "../../../../modules/aws/vpc"
  region = var.region
  env    = var.env

  vpc_name           = "${var.cluster_name_prefix}-${var.env}-vpc"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway

  # Tag subnets with cluster name so EKS Load Balancer
  # Controller can discover which subnets to use
  eks_cluster_name = var.cluster_name
  tags = var.tags
}