############################################
# modules/aws/eks/main.tf
# Purpose:
# - Create an EKS cluster and managed node groups (AWS resources only).
#
# Student notes:
# - Modules should NOT define provider blocks inside them in modern Terraform.
# - Providers are configured in the ROOT (env) folder and passed in automatically.
############################################
locals {
  # Cluster name is stable and environment-specific
  # NOTE: If you want uniqueness, add suffix back in:
  # cluster_name = "${var.cluster_name_prefix}-${var.env}-eks-${random_string.suffix.result}"
  cluster_name = "${var.cluster_name_prefix}-${var.env}-eks"

  common_tags = merge(
    {
      Environment = var.env
      ManagedBy   = "Terraform"
      Project     = "iBank EKS Infrastructure Project"
    },
    var.tags
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  # Private-only endpoint (production-grade)
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # OK for labs; in strict enterprises you manage access more tightly
  enable_cluster_creator_admin_permissions = true

  # Attach cluster to existing VPC
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Node group defaults
  eks_managed_node_group_defaults = {
    ami_type = var.ami_type
  }

  # Two managed node groups
  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = [var.node_instance_type]

      min_size     = var.ng1_min_size
      max_size     = var.ng1_max_size
      desired_size = var.ng1_desired_size
    }

    two = {
      name           = "node-group-2"
      instance_types = [var.node_instance_type]

      min_size     = var.ng2_min_size
      max_size     = var.ng2_max_size
      desired_size = var.ng2_desired_size
    }
  }

  tags = local.common_tags
}

