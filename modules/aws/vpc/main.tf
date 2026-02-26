########################################################################################
# modules/aws/vpc/main.tf
# Purpose:
# - Create the VPC, public subnets, private subnets
# - Create NAT Gateway so private subnets can reach internet OUTBOUND
#
# - "Public subnet" means it has a route to the Internet Gateway (IGW).
# - "Private subnet" means it does NOT have a route to IGW.
# - Private subnets usually reach the internet using NAT Gateway (outbound only).
########################################################################################

########################################################################################
# Reference Documentation:
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
########################################################################################

# Fetch AZs we can use in the region
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  # Pick the first N AZs
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  ##########################################################
  # Subnet math (important Terraform skill):
  #
  # cidrsubnet(BASE_CIDR, NEW_BITS, NETNUM)
  #
  # If base is /16 and we add 8 bits => /24 subnets
  # Then NETNUM picks which /24 we want.
  #
  # We'll create:
  # - public subnets: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24 ...
  # - private subnets: 10.0.100.0/24, 10.0.101.0/24, 10.0.102.0/24 ...
  ##########################################################

  public_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  private_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 100 + i)
  ]

  common_tags = merge(
    {
      Environment = var.env
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Use the community VPC module (battle-tested)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs  = local.azs

  ##########################################################
  # Why do we need PUBLIC subnets at all?
  #
  # Because NAT Gateway must be placed in a public subnet.
  #
  # Even though your WORKERS are private, they often need
  # outbound internet (e.g., pull container images).
  #
  # So:
  # - public subnets: host NAT (and optional public ALB later)
  # - private subnets: host EKS worker nodes
  ##########################################################
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway = true

  # Cheaper: one NAT for the whole VPC (single point of failure)
  # More resilient: NAT per AZ (costs more)
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                      = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}"        = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                               = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}"        = "shared"
  }

  tags = local.common_tags
}
