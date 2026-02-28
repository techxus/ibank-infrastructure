############################################
# modules/aws/eks/main.tf
# Purpose:
# - Create an EKS cluster and managed node groups (AWS resources only).
#
# Student notes:
# - Modules should NOT define provider blocks inside them in modern Terraform.
# - Providers are configured in the ROOT (env) folder and passed in automatically.
############################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type
  }

  eks_managed_node_groups = {
    one = {
      name           = "${var.cluster_name}-ng1"
      instance_types = [var.node_instance_type]
      min_size       = var.ng1_min_size
      max_size       = var.ng1_max_size
      desired_size   = var.ng1_desired_size
    }
    two = {
      name           = "${var.cluster_name}-ng2"
      instance_types = [var.node_instance_type]
      min_size       = var.ng2_min_size
      max_size       = var.ng2_max_size
      desired_size   = var.ng2_desired_size
    }
  }

  tags = var.tags
}