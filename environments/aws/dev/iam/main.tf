############################################
# environments/aws/dev/iam/main.tf
############################################

############################################
# ALB CONTROLLER
############################################
resource "aws_iam_role" "alb_controller" {
  name = "ibank-${var.env}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(var.tags, { Purpose = "alb-controller" })
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
resource "aws_iam_role" "crossplane" {
  name = "ibank-${var.env}-crossplane"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(var.tags, { Purpose = "crossplane" })
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
resource "aws_iam_role" "vault" {
  name = "ibank-${var.env}-vault"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(var.tags, { Purpose = "vault" })
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
# EXTERNAL-DNS
############################################
resource "aws_iam_role" "external_dns" {
  name = "ibank-${var.env}-external-dns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
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
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# Pod Identity Associations
# Links IAM roles to Kubernetes service accounts
# No OIDC required — agent handles token exchange
############################################
resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller.arn
}

resource "aws_eks_pod_identity_association" "crossplane" {
  cluster_name    = var.cluster_name
  namespace       = "crossplane-system"
  service_account = "crossplane"
  role_arn        = aws_iam_role.crossplane.arn
}

resource "aws_eks_pod_identity_association" "vault" {
  cluster_name    = var.cluster_name
  namespace       = "vault"
  service_account = "vault"
  role_arn        = aws_iam_role.vault.arn
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns-${var.env}"
  role_arn        = aws_iam_role.external_dns.arn
}

############################################
# environments/aws/dev/iam/rds.tf
# RDS master password — generated once,
# stored in SSM SecureString, never in git.
# Works for dev/stage/prod via var.env.
############################################

resource "random_password" "rds_master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"
}

resource "aws_ssm_parameter" "rds_master_password" {
  name        = "/ibank/${var.env}/rds/master-password"
  type        = "SecureString"
  value       = random_password.rds_master.result
  description = "RDS master password for ibank ${var.env}"
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]  # never rotate automatically
  }
}

resource "aws_ssm_parameter" "rds_master_username" {
  name  = "/ibank/${var.env}/rds/master-username"
  type  = "String"
  value = "ibankadmin"
  tags  = var.tags
}