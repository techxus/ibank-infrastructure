############################################
# global/iam.tf
# GitHub Actions OIDC — keyless CI/CD auth
############################################

resource "aws_iam_openid_connect_provider" "github" {
  # GitHub's OIDC endpoint — this is the identity provider
  # that GitHub Actions uses to prove who it is to AWS.
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  # This is the role GitHub Actions will assume.
  # It defines WHAT can assume it (trust policy)
  # and WHAT it can do (permissions policy below).
  name = "ibank-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Only the GitHub OIDC provider can assume this role
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          # Only THIS specific GitHub org/repo can assume this role.
          # Prevents other GitHub repos from using your AWS account.
          "token.actions.githubusercontent.com:sub" : "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = merge({ ManagedBy = "Terraform" }, var.tags)
}

resource "aws_iam_role_policy" "github_actions_permissions" {
  name = "ibank-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ############################################
      # S3 — read and write Terraform state files
      # Terragrunt needs these to read and write
      # terraform.tfstate files for all workspaces.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketVersioning",      # ← add this
          "s3:PutBucketVersioning",      # ← add this too (needed for bootstrap)
          "s3:GetEncryptionConfiguration", # ← and this (needed for bootstrap)
          "s3:GetBucketPolicy",          # ← and this
          "s3:GetBucketAcl",             # ← and this
          "s3:GetBucketLocation"         # ← and this (needed by Terragrunt)
        ]
        Resource = [
          "arn:aws:s3:::ibank-terraform-state",
          "arn:aws:s3:::ibank-terraform-state/*"
        ]
      },

      ############################################
      # DynamoDB — state locking
      # Prevents two pipeline runs from applying
      # at the same time and corrupting state.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:121897425968:table/ibank-terraform-locks"
      },

      ############################################
      # KMS — decrypt and encrypt state files
      # The state bucket uses KMS encryption so
      # the role needs permission to use the key.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "arn:aws:kms:us-east-1:121897425968:alias/ibank-terraform-state"
      },

      ############################################
      # ECR — push and pull container images
      # CI/CD pipeline pushes built images to ECR.
      # EKS pulls images from ECR to run containers.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy"
        ]
        Resource = "*"
      },

      ############################################
      # IAM — manage roles and policies
      # Terraform creates IAM roles for EKS node
      # groups, IRSA, service accounts, etc.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags",
          "iam:UpdateAssumeRolePolicy"
        ]
        Resource = "*"
      },

      ############################################
      # EC2 and VPC networking
      # Needed to create VPC, subnets, NAT gateway,
      # internet gateway, security groups, etc.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },

      ############################################
      # EKS — create and manage cluster
      # Full EKS permissions to create cluster,
      # node groups, addons, access entries, etc.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },

      ############################################
      # CloudWatch logs — EKS control plane logs
      # EKS writes control plane logs to CloudWatch.
      ############################################
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogDelivery",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:TagLogGroup",
          "logs:ListTagsLogGroup",
          "logs:ListTagsForResource",
          "logs:TagResource"
        ]
        Resource = "*"
      },

      ############################################
      # KMS — general key management for EKS
      # EKS uses KMS to encrypt Kubernetes secrets
      # stored in etcd (the cluster database).
      ############################################
      {
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:CreateAlias",
          "kms:DescribeKey",
          "kms:EnableKeyRotation",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:ListAliases",
          "kms:ListKeys",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })
}