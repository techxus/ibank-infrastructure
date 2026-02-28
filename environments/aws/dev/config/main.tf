############################################
# config/main.tf
#
# Stores all environment configuration
# in SSM Parameter Store.
#
# Single source of truth for:
# - pipelines
# - applications
# - developers
############################################
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ssm_parameter" "region" {
  name  = "/ibank/${var.env}/region"
  type  = "String"
  value = var.region
  tags  = var.tags
}

resource "aws_ssm_parameter" "domain" {
  name  = "/ibank/${var.env}/domain"
  type  = "String"
  value = var.domain
  tags  = var.tags
}

resource "aws_ssm_parameter" "account_id" {
  name  = "/ibank/${var.env}/account-id"
  type  = "String"
  value = data.aws_caller_identity.current.account_id
  tags  = var.tags
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "/ibank/${var.env}/cluster-name"
  type  = "String"
  value = var.cluster_name
  tags  = var.tags
}