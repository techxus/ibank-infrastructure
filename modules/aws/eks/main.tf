############################################
# modules/aws/eks/main.tf
#
# PURPOSE:
# Creates an EKS cluster using the official
# terraform-aws-modules/eks module, plus all
# supporting resources needed for IRSA to work.
#
# IRSA = IAM Roles for Service Accounts.
# Pods assume IAM roles via OIDC without
# storing any credentials inside the cluster.
#
# STUDENT NOTES:
# The terraform-aws-modules/eks module creates
# an OIDC provider internally BUT computes the
# wrong thumbprint. We disable the built-in one
# (enable_irsa = false) and create our own with
# the correct pinned thumbprint + ignore_changes
# so Terraform never overwrites it.
#
# The thumbprint 9e99a48a... is the SHA1 of the
# root CA cert for oidc.eks.us-east-1.amazonaws.com
# AWS validates this when pods exchange tokens.
############################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Disable built-in OIDC provider creation.
  # We manage it ourselves below with a pinned
  # thumbprint so Terraform never breaks IRSA.
  enable_irsa = false

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

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi.arn
    }
  }

  tags = var.tags
}

############################################
# OIDC Provider
#
# We own this resource — NOT the EKS module.
#
# WHY: terraform-aws-modules/eks computes the
# OIDC thumbprint dynamically via a TLS lookup.
# This lookup returns different intermediate CA
# certs depending on timing and AWS infra state
# causing the thumbprint to flip on every apply.
#
# FIX: Pin the thumbprint to the known correct
# value and use ignore_changes so Terraform
# never touches it again after creation.
############################################
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = module.eks.cluster_oidc_issuer_url

  lifecycle {
    # Never let Terraform recompute or overwrite
    # the thumbprint after initial creation.
    # Changing it breaks all IRSA authentication.
    ignore_changes = [thumbprint_list]
  }

  tags = var.tags
}

############################################
# EBS CSI Driver IRSA Role
#
# The EBS CSI driver needs permission to create
# and attach EBS volumes on behalf of pods.
# This role is assumed via IRSA — the pod's
# service account token is exchanged for
# temporary AWS credentials at runtime.
############################################
data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}