resource "aws_iam_role_policy" "github_actions_permissions" {
  name = "ibank-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
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
      }
    ]
  })
}