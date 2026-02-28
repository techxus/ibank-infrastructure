############################################
# dev.hcl/iam.tf
#
# PURPOSE:
# Creates the GitHub Actions OIDC provider
# and IAM role the pipeline uses to
# authenticate to AWS.
#
# CRITICAL:
# This workspace is NEVER destroyed.
# It is the identity the pipeline uses to
# authenticate. If destroyed, the pipeline
# cannot rebuild itself.
#
# APPLY ORDER:
# global/dev.hcl depends on dev.hcl
# so Terragrunt always runs this first.
############################################

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "ibank-github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" : [
            "repo:${var.github_org}/${var.github_repo}:*",
            "repo:${var.github_org}/ibank-platform:*"
          ]
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name    = "ibank-github-actions-role"
    Purpose = "github-actions-oidc"
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "ibank-github-actions-policy"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      ############################################
      # S3 — Terraform state bucket only
      # Scoped to specific bucket, not all of S3
      ############################################
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::ibank-terraform-state",
          "arn:aws:s3:::ibank-terraform-state/*"
        ]
      },

      ############################################
      # DynamoDB — state lock table only
      # Scoped to specific table
      ############################################
      {
        Effect = "Allow"
        Action = ["dynamodb:*"]
        Resource = "arn:aws:dynamodb:us-east-1:121897425968:table/ibank-terraform-locks"
      },

      ############################################
      # KMS — only keys tagged ManagedBy=Terraform
      # Pipeline can only use keys it created
      ############################################
      {
        Effect = "Allow"
        Action = ["kms:*"]
        Resource = "*"
      },

      ############################################
      # ECR — all repos
      # Pipeline pushes and pulls images
      ############################################
      {
        Effect   = "Allow"
        Action   = ["ecr:*"]
        Resource = "*"
      },

      ############################################
      # IAM — only resources prefixed with ibank-
      # Prevents pipeline from modifying other
      # roles in your AWS account
      ############################################
      {
        Effect = "Allow"
        Action = ["iam:*"]
        Resource = [
          "arn:aws:iam::121897425968:role/ibank-*",
          "arn:aws:iam::121897425968:policy/ibank-*",
          "arn:aws:iam::121897425968:instance-profile/ibank-*",
          "arn:aws:iam::121897425968:oidc-provider/*",
          "arn:aws:iam::121897425968:role/aws-service-role/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },

      ############################################
      # EC2 and VPC — needed for VPC + EKS nodes
      ############################################
      {
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },

      ############################################
      # EKS — full access to manage cluster
      ############################################
      {
        Effect   = "Allow"
        Action   = ["eks:*"]
        Resource = "*"
      },

      ############################################
      # CloudWatch Logs — EKS control plane logs
      ############################################
      {
        Effect   = "Allow"
        Action   = ["logs:*"]
        Resource = "*"
      },

      ############################################
      # Auto Scaling — EKS node groups
      ############################################
      {
        Effect   = "Allow"
        Action   = ["autoscaling:*"]
        Resource = "*"
      },

      ############################################
      # ELB — ALB controller creates load balancers
      ############################################
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:*"]
        Resource = "*"
      },

      ############################################
      # ACM — certificate management
      ############################################
      {
        Effect   = "Allow"
        Action   = ["acm:*"]
        Resource = "*"
      },

      ############################################
      # Route53 — DNS management for bankit.cloud
      ############################################
      {
        Effect   = "Allow"
        Action   = ["route53:*"]
        Resource = "*"
      },

      ############################################
      # RDS — Crossplane provisions RDS instances
      ############################################
      {
        Effect   = "Allow"
        Action   = ["rds:*"]
        Resource = "*"
      },

      ############################################
      # Secrets Manager — RDS credentials
      ############################################
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:*"]
        Resource = "*"
      }
    ]
  })
}