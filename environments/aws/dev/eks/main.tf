############################################
# environments/aws/dev/eks/main.tf
# Purpose:
# - Create EKS cluster for dev environment
# - VPC outputs come from Terragrunt dependency
#   declared in root.hcl — no remote
#   state data blocks needed here.
############################################
module "eks" {
  source = "../../../../modules/aws/eks"
  env             = var.env
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  node_instance_type = var.node_instance_type

  ng1_min_size     = var.ng1_min_size
  ng1_max_size     = var.ng1_max_size
  ng1_desired_size = var.ng1_desired_size

  ng2_min_size     = var.ng2_min_size
  ng2_max_size     = var.ng2_max_size
  ng2_desired_size = var.ng2_desired_size

  tags = merge(
    {
      Environment = var.env
    },
    var.tags
  )
}

############################################
# Configure Kubernetes and Helm providers
# These need the EKS cluster to exist first.
############################################

data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}