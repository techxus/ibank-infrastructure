############################################################
# DEV EKS Environment Stack
#
# Responsibilities:
# 1) Read networking remote state
# 2) Create EKS cluster
# 3) Configure Kubernetes + Helm providers
# 4) Install AWS Load Balancer Controller (production IRSA)
############################################################

############################################################
# 1. Read Networking Workspace State
############################################################

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "ibank-terraform-state"
    key    = "environments/aws/dev/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "ibank-terraform-state"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "../../../modules/aws/vpc"

  region = var.region
  env    = var.env

  vpc_name           = "${var.cluster_name_prefix}-${var.env}-vpc"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway

  # optional but recommended once EKS name is known:
  eks_cluster_name = "${var.cluster_name_prefix}-${var.env}-eks"

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Project     = "iBank"
  }
}

############################################################
# 2. Create EKS Cluster
############################################################

module "eks" {
  source = "../../../modules/aws/eks"

  region = var.region
  env    = var.env

  cluster_name_prefix = var.cluster_name_prefix
  cluster_version     = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_type = var.node_instance_type

  ng1_min_size     = var.ng1_min_size
  ng1_max_size     = var.ng1_max_size
  ng1_desired_size = var.ng1_desired_size

  ng2_min_size     = var.ng2_min_size
  ng2_max_size     = var.ng2_max_size
  ng2_desired_size = var.ng2_desired_size

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Project     = "iBank"
  }
}

############################################################
# 3. Configure Kubernetes + Helm Providers
############################################################

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}
