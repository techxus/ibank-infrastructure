############################################
# environments/aws/dev/iam/main.tf
#
# PURPOSE:
# Creates IRSA roles for tools running
# inside EKS. IRSA = IAM Roles for Service
# Accounts. Pods assume these roles via OIDC
# without storing any credentials.
#
# Roles:
# - ALB Controller  → creates AWS load balancers
# - Crossplane      → provisions RDS and other AWS resources
# - Vault           → auto-unseal via KMS
############################################

locals {
  oidc_issuer = replace(var.cluster_oidc_issuer_url, "https://", "")
}

############################################
# ALB CONTROLLER
############################################

data "aws_iam_policy_document" "alb_controller_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "ibank-${var.env}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume.json
  tags               = merge(var.tags, { Purpose = "alb-controller" })
}

resource "aws_iam_role_policy" "alb_controller" {
  name = "ibank-${var.env}-alb-controller-policy"
  role = aws_iam_role.alb_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateServiceLinkedRole",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "elasticloadbalancing:*",
        "acm:ListCertificates",
        "acm:DescribeCertificate",
        "cognito-idp:DescribeUserPoolClient",
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "shield:GetSubscriptionState",
        "shield:DescribeProtection",
        "shield:CreateProtection",
        "shield:DeleteProtection"
      ]
      Resource = "*"
    }]
  })
}

############################################
# CROSSPLANE
############################################

data "aws_iam_policy_document" "crossplane_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:crossplane-system:crossplane"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "crossplane" {
  name               = "ibank-${var.env}-crossplane"
  assume_role_policy = data.aws_iam_policy_document.crossplane_assume.json
  tags               = merge(var.tags, { Purpose = "crossplane" })
}

resource "aws_iam_role_policy" "crossplane" {
  name = "ibank-${var.env}-crossplane-policy"
  role = aws_iam_role.crossplane.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds:*",
        "ec2:*",
        "elasticache:*",
        "kafka:*",
        "secretsmanager:*",
        "kms:*",
        "iam:PassRole"
      ]
      Resource = "*"
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.region
        }
      }
    }]
  })
}

############################################
# VAULT
############################################

data "aws_iam_policy_document" "vault_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:vault:vault"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vault" {
  name               = "ibank-${var.env}-vault"
  assume_role_policy = data.aws_iam_policy_document.vault_assume.json
  tags               = merge(var.tags, { Purpose = "vault" })
}

resource "aws_iam_role_policy" "vault" {
  name = "ibank-${var.env}-vault-policy"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      Resource = var.vault_kms_key_arn
    }]
  })
}

############################################
# external-dns IRSA role
# Allows external-dns to manage Route53
############################################
resource "aws_iam_role" "external_dns" {
  name = "ibank-${var.env}-external-dns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:external-dns:external-dns"
          "${var.cluster_oidc_issuer_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "external_dns" {
  name = "ibank-${var.env}-external-dns-policy"
  role = aws_iam_role.external_dns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })
}
