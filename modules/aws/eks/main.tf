############################################
# modules/aws/eks/main.tf
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

  # Disable the module's OIDC provider creation
  # We manage it ourselves to control the thumbprint
  create_iam_openid_connect_provider = false

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

############################################
# OIDC Provider - managed explicitly
# AWS EKS thumbprint for us-east-1:
# 9e99a48a9960b14926bb7f3b02e22da2b0ab7280
# The community module computes the wrong
# thumbprint via tls_certificate data source.
# AWS actually ignores thumbprint for EKS
# OIDC providers but it must be syntactically
# valid so we hardcode the correct AWS root CA.
############################################
resource "aws_iam_openid_connect_provider" "this" {
  url             = module.eks.cluster_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-irsa"
  })
}