############################################
# global/iam.tf
# GitHub Actions OIDC — keyless CI/CD auth
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
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::ibank-terraform-state",
          "arn:aws:s3:::ibank-terraform-state/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:*"]
        Resource = "arn:aws:dynamodb:us-east-1:121897425968:table/ibank-terraform-locks"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecr:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["eks:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["autoscaling:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sts:*"]
        Resource = "*"
      }
    ]
  })
}